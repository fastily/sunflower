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
    ///   - longestEdge: The max height/width in pixels
    /// - Returns: The downsampled version of `imageURL` as a `CGImage`, otherwise `nil` if something went wrong.
    static func downsample(_ imageURL: URL, _ longestEdge: Int) -> CGImage? {

        let opts = [kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceShouldCacheImmediately: true, kCGImageSourceCreateThumbnailWithTransform: true, kCGImageSourceThumbnailMaxPixelSize: CGFloat(longestEdge)] as CFDictionary
        if let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary), let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, opts) {
            return downsampledImage
        }

        return nil
    }

    ///  Extracts the creation date from the specified file's EXIF if possible.  Returns `nil` otherwise.
    /// - Parameter url: The path to the file to get the creation date from
    /// - Returns: The creation date, or `nil` if the date was not found.
    static func dateFromExif(_ url: URL) -> String? {
        if let src = CGImageSourceCreateWithURL(url as CFURL, nil), let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil), let d = ((props as? [String: Any])?["{Exif}"] as? [String: Any])?["DateTimeOriginal"] as? String  {
            let l = d.split(separator: " ")
            return "\(l[0].description.replacingOccurrences(of: ":", with: "-")) \(l[1])"
        }

        return nil
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

        for c in modelData.uploadCandinates.values {
            c.details.formatForUpload()

            if titleIsBad(c.details.title, hasGlobalTitle) {  // check for illegal chars in titles
                return "\"\(c.details.title)\" is not a valid file title for Commons"
            }
            else if !FileManager.default.fileExists(atPath: c.path.path) { // check for renamed/deleted files
                return "\"\(c.path.lastPathComponent)\" could not be found"
            }
        }

        return nil
    }
    

    /// Performs an upload with the specified `UploadCandinate` objects in `modelData`.  CAVEAT: Does not perform any sanity checks, put all sanity checking code in `preflightCheck()`.
    /// - Parameters:
    ///   - modelData: The `ModelData` object containing hte `UploadCandinate` objects to upload
    ///   - filesToUpload: The list of files to upload
    static func performUploads(_ modelData: ModelData, _ filesToUpload: [URL]) async {
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let today = df.string(from: Date())

        var globalTitleCnt = 0
        var title = ""

        for (i, f) in filesToUpload.enumerated() {

            if Task.isCancelled {
                break
            }

            let currUploadCandinate = modelData.uploadCandinates[f]!
            
            // reset progress bar for the current file being uploaded
            await MainActor.run {
                modelData.uploadState.currentFileName = f.lastPathComponent
                modelData.uploadState.totalProgress = Double(i)/Double(filesToUpload.count)
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
            let result: Status = await modelData.wiki.upload(f, title, desc, modelData) ? .success : .error
            await MainActor.run {
                currUploadCandinate.uploadStatus = result
            }
        }
    }
    
}
