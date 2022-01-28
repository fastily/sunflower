import Combine
import Foundation
import SwiftUI


class Desc: ObservableObject {
    @Published var title = ""
    @Published var desc = ""
    @Published var source = ""
    @Published var date = ""
    @Published var author = "~~~~"
    @Published var permission = ""
    @Published var cat = ""
    @Published var lic = ""
}


/// Enum which represents the upload status of a file.  Supports the UploadStatus class.
enum Status {
    case standby, success, error
}

class UploadStatus: Hashable, ObservableObject {
    var path: URL
    
    /// The actual upload status
    @Published var status: Status
    
//    @Published var isUploaded = false
    
    init(_ path: URL, _ status: Status = .standby) {
        self.path = path
        self.status = status
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
    
    /// Makes this object comparable.  Objects are equal if they have the same path
    /// - Returns: true if the two UploadStatus objects are equal
    static func == (lhs: UploadStatus, rhs: UploadStatus) -> Bool {
        lhs.path == rhs.path
    }
}


class Media: Hashable {   
    var details = Desc()
     
    var path: URL
    
    var name: String {
        path.lastPathComponent
    }
    
    var thumb: Image {
//        guard let img = NSImage(byReferencingFile: path.path) else {
//            return Image("Example")
//        }
  
//        return Image(nsImage: img)
        
        guard let img = downsample(imageAt: path) else {
            return Image("Example")
        }
        
        return img
    }
    
    init(path: URL) {
        self.path = path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
    
    // inspired by https://medium.com/@zippicoder/downsampling-images-for-better-memory-consumption-and-uicollectionview-performance-35e0b4526425
    func downsample(imageAt imageURL: URL, to pointSize: CGSize = CGSize(width: 75, height: 75), scale: CGFloat = 1.0) -> Image? {

        // Create an CGImageSource that represent an image
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
            return nil
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
            return nil
        }
        
        // Return the downsampled image as UIImage
        return Image(decorative: downsampledImage, scale:scale)
    }
    
    
    static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.path == rhs.path
    }
}

enum MainButtonState {
    case notLoggedIn, standby, inProgress
}


class ModelData: ObservableObject {
    var globalDesc = Desc()
    
    @Published var mainButtonState = MainButtonState.notLoggedIn
    
    @Published var ml = [URL:Media]()
    
    @Published var ulStatus = [UploadStatus]()
    
//    // hike data never changes, so no need to mark it as @Published
//    var hikes: [Hike] = load("hikeData.json")
}
