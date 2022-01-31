import Foundation
import SwiftUI

class UploadManager {


    // inspired by https://medium.com/@zippicoder/downsampling-images-for-better-memory-consumption-and-uicollectionview-performance-35e0b4526425
    static func downsampleImage(imageAt imageURL: URL, to pointSize: CGSize = CGSize(width: 75, height: 75), scale: CGFloat = 1.0) -> Image {

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



    static func performUploads(_ modelData: ModelData, _ i: Int = 0, completion: @escaping () -> () ) {



    }

}
