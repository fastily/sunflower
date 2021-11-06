import Combine
import Foundation
import SwiftUI


struct Desc:Hashable {
    var desc = ""
    var source = ""
    var date = ""
    var author = "~~~~"
    var permission = ""
    var cat = ""
    var lic = ""
}


struct Media: Identifiable, Hashable {
    var id = UUID()
    
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
}


class ModelData: ObservableObject {
   
    var globalDesc = Desc()
    
    @Published var fl: [Media] = []
    
    
    init() {
        
    }
    
    init(_ fl:[Media]) {
        self.fl = fl
    }
    
//    // hike data never changes, so no need to mark it as @Published
//    var hikes: [Hike] = load("hikeData.json")
    

    
}

