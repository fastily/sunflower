import Combine
import Foundation
import SwiftUI


struct Desc {
    var desc = ""
    var source = ""
    var date = ""
    var author = "~~~~"
    var permission = ""
    var cat = ""
    var lic = ""
}


struct Media {
    
    var details = Desc()
    
    var isUploaded = false
    
    var name = "Example.jpg"
    
    
//    var path = "~/Desktop/20190831_221325.jpg"
//    var thumbnail: Image {
//        if let img = NSImage(byReferencingFile: path) {
//
//            return Image(nsImage: img)
//        }
//        else {
//            return Image("Example")
//        }
//
//    }
    
    var thumb = Image("Example")
}



// An observable object needs to publish any changes to its data, so that its subscribers can pick up the change.

class ModelData: ObservableObject {
   
    var globalDesc = Desc()

    @Published var fl: [Media] = [Media()]
    
//    // hike data never changes, so no need to mark it as @Published
//    var hikes: [Hike] = load("hikeData.json")
    

    
}

