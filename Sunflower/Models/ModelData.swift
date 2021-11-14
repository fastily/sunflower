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



class UploadStatus: Hashable, ObservableObject {
    var path: URL
    
    @Published var isUploaded = false
    
    init(_ path: URL) {
        self.path = path
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
    
    static func == (lhs: UploadStatus, rhs: UploadStatus) -> Bool {
        lhs.path == rhs.path
    }
}


class Media: Hashable {
//    var id = UUID()
    
    var details = Desc()
    
    var isUploaded = false
     
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
    
    
    
    init(path: URL, isUploaded: Bool = false) {
        self.path = path
        
        self.isUploaded = isUploaded
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
    
    var fl = [Media]()
    
    @Published var ml = [URL:Media]()
    
    @Published var ulStatus = [UploadStatus]()
    
    
    init() {
        
    }
    
    init(_ fl:[Media]) {
        self.fl = fl
    }
    
//    // hike data never changes, so no need to mark it as @Published
//    var hikes: [Hike] = load("hikeData.json")
    

    
}

