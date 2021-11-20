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
    
//    var isUploaded = false
     
    var path: URL
    
    var name: String {
        path.lastPathComponent
    }
    
    var thumb: Image {
        guard let img = NSImage(byReferencingFile: path.path) else {
            return Image("Example")
        }
        
        return Image(nsImage: img)
    }
    
    init(path: URL) {
        self.path = path
        
//        self.isUploaded = isUploaded
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
    
    static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.path == rhs.path
    }
}


class ModelData: ObservableObject {
    var globalDesc = Desc()
    
    @Published var ml = [URL:Media]()
    
    @Published var ulStatus = [UploadStatus]()
    
//    // hike data never changes, so no need to mark it as @Published
//    var hikes: [Hike] = load("hikeData.json")
}
