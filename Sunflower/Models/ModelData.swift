import Foundation

/// The main storage object which maintains the state of Sunflower
class ModelData: ObservableObject {
    
    /// The interal representation of the global description object.  This is useful for mass uploads
    var globalDesc = Desc()
    
    /// The main shared Wiki object for Sunflower
    let wiki = Wiki()
    
    /// Indicates if the user is logged in or not
    @Published var isLoggedIn = false
    
    /// Tracks the files the user has selected to be uploaded.  Maps a `URL` (pointing to the local file on the user's computer) to an associated `UploadCandinate` object
    @Published var uploadCandinates = [URL:UploadCandinate]()
    
    /// The paths (as `URL`s) to the files to upload.  This exists as an optimization so the entire `MediaList` view doesn't have to be redrawn every time an update occurs.
    @Published var paths = [URL]()

    @Published var uploadState = UploadState()

    /// Adds a file to the list of files to upload
    /// - Parameter path: The path `URL` to the file to upload
    func addFile(_ path: URL) {
        uploadCandinates[path] = UploadCandinate(path)
        paths.append(path)
    }
    
    /// Removes a file from the ilst of files to upload
    /// - Parameter path: The path `URL` to the file to remove from the upload list
    func removeFile(_ path: URL) {
        uploadCandinates.removeValue(forKey: path)
        paths.remove(at: paths.firstIndex(of: path)!)
    }
    
    
    //    // hike data never changes, so no need to mark it as @Published
    //    var hikes: [Hike] = load("hikeData.json")
}
