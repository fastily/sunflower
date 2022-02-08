import Foundation

/// Represents a file for upload
class UploadCandinate: ObservableObject {
    
    /// Indicates the wheter the file has been uploaded (success/error) or not.
    @Published var uploadStatus = Status.standby
    
    ///  The file description object associated with this `UploadCandinate`
    let details = Desc()
    
    /// The path to the file to upload
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
