import Foundation

class UploadCandinate: ObservableObject {

    @Published var uploadStatus = Status.standby

    let details = Desc()

    let path: URL

    /// Initializer, creates a new UploadCandinate with the specified path `URL`
    /// - Parameter path: The path to the file to upload
    init(_ path: URL ) {
        self.path = path
    }
}

/// Enum which represents the upload status of a file.  Supports the `UploadStatus` class.
enum Status {
    case standby, success, error
}
