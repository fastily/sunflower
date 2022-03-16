import Foundation

/// Represents a file for upload
class UploadCandinate: ObservableObject {
    
    /// Indicates the wheter the file has been uploaded (success/error) or not.
    @Published var uploadStatus = Status.standby
    
    ///  The file description object associated with this `UploadCandinate`
    @Published var details = Desc()

    /// A scaled-down thumbnail for this upload candinate, if applicable.  Can be displayed in the sidebar.
    let thumbnail: CGImage?

    /// The path to the file to upload
    let path: URL
    
    /// Initializer, creates a new UploadCandinate with the specified path `URL`
    /// - Parameter path: The path to the file to upload
    init(_ path: URL) {
        self.path = path

        if UploadUtils.isDisplayableFile(path), let thumbnail = UIUtils.downsample(path, 55) {
            self.thumbnail = thumbnail
        }
        else {
            thumbnail = nil
        }

    }
}

/// Enum which represents the upload status of a file.  Supports the `UploadStatus` class.
enum Status {
    case standby, success, error
}
