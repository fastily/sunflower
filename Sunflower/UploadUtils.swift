import Foundation
import SwiftUI


/// Miscellaneous convenience methods for managing and uploading images
class UploadUtils {

    private static let indexTemplate = "{i}"

    private static let badTitleChars = CharacterSet(charactersIn: "#<>[]{}_|:")


    /// Downsamples a raster image so it doesn't take up copious amounts of memory when displayed.  Inspired by [this writeup](https://medium.com/@zippicoder/downsampling-images-for-better-memory-consumption-and-uicollectionview-performance-35e0b4526425).
    /// - Parameters:
    ///   - imageURL: The path to the image to downsample
    ///   - pointSize: The max height/width in pixels
    ///   - scale: The dpi scale to use
    /// - Returns: A downsized image, ready for displaying
    static func downsampleImage(_ imageURL: URL, to pointSize: CGSize = CGSize(width: 55, height: 55), scale: CGFloat = 1.0) -> Image {

        // Create an CGImageSource that represent an image
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
            return Image("Example")
        }

        // Calculate the desired dimension
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale

        // Perform downsampling
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return Image("Example")
        }

        // Return the downsampled image as UIImage
        return Image(decorative: downsampledImage, scale:scale)
    }


    private static func titleIsBad(_ title: String, _ emptyOk: Bool = true) -> Bool {
        CharacterSet(charactersIn: title).isDisjoint(with: badTitleChars) && (emptyOk || title.isEmpty)
    }

    private static func titleFromGD(_ modelData: ModelData, _ cnt: Int = 0) -> String {
        modelData.globalDesc.title.replacingOccurrences(of: indexTemplate, with: String(cnt)).replacingOccurrences(of: "{d}", with: "foo")
    }

    private static func defaultIfEmpty(_ s: String, _ d: String) -> String {
        s.isEmpty ? d : s
    }

    static func preflightCheck(_ modelData: ModelData) -> String? {
        modelData.globalDesc.formatForUpload()
        let hasGlobalTitle = !modelData.globalDesc.title.isEmpty

        // check for illegal chars in global title
        if hasGlobalTitle {
            if !modelData.globalDesc.title.contains(indexTemplate) {
                return "Global title must contain index '\(indexTemplate)'"
            }
            else if titleIsBad(titleFromGD(modelData)) {
                return "Global title contains invalid characters"
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

            await MainActor.run {
                modelData.uploadState.currentFileName = f.lastPathComponent
                modelData.uploadState.totalProgress = Double(i)/Double(modelData.paths.count)
                modelData.uploadState.currFileProgress = 0.0
            }

            if currUploadCandinate.details.title.isEmpty {
                globalTitleCnt += 1
                title = titleFromGD(modelData, globalTitleCnt).replacingOccurrences(of: "{d}", with: today)
            }
            else {
                title = currUploadCandinate.details.title
            }

            let desc = """
=={{int:filedesc}}==
{{Information
|description=\(defaultIfEmpty(modelData.globalDesc.desc, currUploadCandinate.details.desc))
|date=\(defaultIfEmpty(modelData.globalDesc.date, currUploadCandinate.details.date))
|source=\(defaultIfEmpty(modelData.globalDesc.source, currUploadCandinate.details.source))
|author=\(defaultIfEmpty(modelData.globalDesc.author, currUploadCandinate.details.author))
|permission=\(defaultIfEmpty(modelData.globalDesc.permission, currUploadCandinate.details.permission))
}}

=={{int:license-header}}==
\(defaultIfEmpty(modelData.globalDesc.lic, currUploadCandinate.details.lic))

\(defaultIfEmpty(modelData.globalDesc.cat, currUploadCandinate.details.cat))
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
