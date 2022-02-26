import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// Miscellaneous convenience methods for managing and uploading images
class UploadUtils {
    
    /// The image extensions which are supported by Sunflower for thumbnailing/previewing
    static let displayableImgExts: Set = [UTType(filenameExtension: "jpg")!, UTType(filenameExtension: "png")!]
    
    /// The index substring to replace with an index in global titles at upload time
    private static let indexTemplate = "{i}"
    
    /// The set of illegal title characters on MediaWiki
    private static let badTitleChars = CharacterSet(charactersIn: "#<>[]{}_|:")
    
    /// Downsamples a raster image so it doesn't take up copious amounts of memory when displayed.  Inspired by [this writeup](https://medium.com/@zippicoder/downsampling-images-for-better-memory-consumption-and-uicollectionview-performance-35e0b4526425).
    /// - Parameters:
    ///   - imageURL: The path to the image to downsample
    ///   - pointSize: The max height/width in pixels
    ///   - scale: The dpi scale to use
    /// - Returns: A downsized image, ready for displaying
    static func downsampleImage(_ imageURL: URL, to pointSize: CGSize = CGSize(width: 55, height: 55), scale: CGFloat = 1.0) -> Image {

        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale // Calculate the desired max dimension in pixels

        if let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary), let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary) {
            return Image(decorative: downsampledImage, scale:scale)
        }

        return Image("sunflower-generic")
    }
    
    /// Check if the specified file is supported for thumbnailing.  See also - `displayableImgExts`
    /// - Parameter p: The file to check
    /// - Returns: `true` if the file can be thumbnailed.
    static func isDisplayableFile(_ p: URL) -> Bool {
        displayableImgExts.contains(UTType(filenameExtension: p.pathExtension)!)
    }
    
    
    /// Checks if a title is a valid title on MediaWiki
    /// - Parameters:
    ///   - title: The title to check
    ///   - emptyOk: Flag indicating if an empty title is acceptable.  If set to`true`, then if `title` is empty, `true` will be returned.
    /// - Returns: `true` if `title` is a valid MediaWiki title
    private static func titleIsBad(_ title: String, _ emptyOk: Bool = true) -> Bool {
        !CharacterSet(charactersIn: title).isDisjoint(with: badTitleChars) || !emptyOk && title.isEmpty
    }
    
    /// Convenience method, generates a title based on the global title specified in `modelData`.
    /// - Parameters:
    ///   - modelData: The ModelData object to use
    ///   - cnt: The current upload count
    ///   - today: Today's date
    /// - Returns: The title based on the global title
    private static func titleFromGD(_ modelData: ModelData, _ cnt: Int = 0, _ today: String = "") -> String {
        modelData.globalDesc.title.replacingOccurrences(of: indexTemplate, with: String(cnt)).replacingOccurrences(of: "{d}", with: today)
    }
    
    /// Convenience method, returns a default string, `d` if `s` is empty, otherwise just returns `s`.
    /// - Parameters:
    ///   - s: The `String` to check.  If empty, return `d`.
    ///   - d: The defualt string to return
    /// - Returns: `s`, or `d` if `s` is empty
    private static func defaultIfEmpty(_ s: String, _ d: String) -> String {
        s.isEmpty ? d : s
    }
    
    /// Performs preflight sanity checks and upload form field normalizations.  If issues are found, an error message will be returned, and this shoudl be shown to the user.
    /// - Parameter modelData: The `ModelData` to use.
    /// - Returns: An error message if something went wrong, otherwise `nil`.
    static func preflightCheck(_ modelData: ModelData) -> String? {
        modelData.globalDesc.formatForUpload()
        let hasGlobalTitle = !modelData.globalDesc.title.isEmpty
        
        let title = modelData.globalDesc.title
        
        // check for illegal chars in global title
        if hasGlobalTitle {
            if !title.contains(indexTemplate) {
                return "Global title must contain a counter '\(indexTemplate)'"
            }
            else if titleIsBad(titleFromGD(modelData)) {
                return "Global title contains invalid characters"
            }
            else if title.range(of: modelData.wiki.extRegex, options: .regularExpression) != nil {
                return "Global title may not contain a file extension"
            }
        }
        
        // check for illegal chars in titles
        for c in modelData.uploadCandinates.values {
            c.details.formatForUpload()

            if titleIsBad(c.details.title, hasGlobalTitle) {
                return "\"\(c.details.title)\" is not a valid file title for Commons"
            }
        }
        
        return nil
    }
    
    
    /// Performs an upload with the specified `UploadCandinate` objects in `modelData`.  CAVEAT: Does not perform any sanity checks, put all sanity checking code in `preflightCheck()`.
    /// - Parameter modelData: The `ModelData` object containing hte `UploadCandinate` objects to upload
    static func performUploads(_ modelData: ModelData) async {
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let today = df.string(from: Date())
        
        var globalTitleCnt = 0
        var title = ""
        
        for (i, f) in modelData.paths.enumerated() {
            let currUploadCandinate = modelData.uploadCandinates[f]!
            
            // reset progress bar for the current file being uploaded
            await MainActor.run {
                modelData.uploadState.currentFileName = f.lastPathComponent
                modelData.uploadState.totalProgress = Double(i)/Double(modelData.paths.count)
                modelData.uploadState.currFileProgress = 0.0
            }
            
            // if using global config, generate a title
            if currUploadCandinate.details.title.isEmpty {
                globalTitleCnt += 1
                title = titleFromGD(modelData, globalTitleCnt, today)
            }
            else {
                title = currUploadCandinate.details.title
            }
            
            // ensure file extension
            title = "\(title.replacingOccurrences(of: modelData.wiki.extRegex, with: "", options: [.regularExpression])).\(currUploadCandinate.path.pathExtension.lowercased())"
            
            let desc = """
=={{int:filedesc}}==
{{Information
|description=\(defaultIfEmpty(currUploadCandinate.details.desc, modelData.globalDesc.desc))
|date=\(defaultIfEmpty(currUploadCandinate.details.date, modelData.globalDesc.date))
|source=\(defaultIfEmpty(currUploadCandinate.details.source, modelData.globalDesc.source))
|author=\(defaultIfEmpty(currUploadCandinate.details.author, modelData.globalDesc.author))
|permission=\(defaultIfEmpty(currUploadCandinate.details.permission, modelData.globalDesc.permission))
}}

=={{int:license-header}}==
\(defaultIfEmpty(currUploadCandinate.details.lic, modelData.globalDesc.lic))

[[Category:Uploaded with Sunflower]]
\(defaultIfEmpty(currUploadCandinate.details.cat, modelData.globalDesc.cat))
"""
            
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000) // hack, allow UI time to catch up
            }
            catch {
                break
            }
            
            let result: Status = await modelData.wiki.upload(f, title, desc, modelData) ? .success : .error
            await MainActor.run {
                currUploadCandinate.uploadStatus = result
            }
        }
    }
    
}
