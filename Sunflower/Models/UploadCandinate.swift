import Foundation

class UploadCandinate: ObservableObject {

    let details = Desc()

    let path: URL

    @Published var uploadStatus = Status.standby

    init(_ path: URL ) {
        self.path = path
    }

//    var thumb: Image {
//        guard let img = downsample(imageAt: path) else {
//            return Image("Example")
//        }
//
//        return img
//    }

}

/// Enum which represents the upload status of a file.  Supports the `UploadStatus` class.
enum Status {
    case standby, success, error
}
