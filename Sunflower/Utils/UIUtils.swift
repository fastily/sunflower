import Foundation
import SwiftUI

/// Miscellaneous convenience methods related to the UI functionality
class UIUtils {

    /// Convenience method, closes a sheet associated wiht the specified presentation mode.
    /// - Parameter presentationMode: The `PresentationMode` environment variable in the view with the sheet to close.
    static func dismissSheet(_ presentationMode: Binding<PresentationMode> ) {
        presentationMode.wrappedValue.dismiss()
        NSApp.mainWindow?.endSheet(NSApp.keyWindow!) // workaround SwiftUI to show dismiss animation
    }

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
}
