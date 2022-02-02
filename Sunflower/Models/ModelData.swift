import Foundation
import SwiftUI

/// Represents the states for the main Upload action button
enum MainButtonState {
    case notLoggedIn, standby, inProgress
}


/// The main storage object which maintains the state of Sunflower
class ModelData: ObservableObject {

    /// The interal representation of the global description object.  This is useful for mass uploads
    var globalDesc = Desc()

    /// The main shared Wiki object for Sunflower
    let wiki = Wiki()

    /// Represents the state of the main action button
    @Published var mainButtonState = MainButtonState.notLoggedIn

    /// Tracks the files the user has selected to be uploaded.  Maps a `URL` (pointing to the local file on the user's computer) to an associated `UploadCandinate` object
    @Published var uploadCandinates = [URL:UploadCandinate]()

    /// The paths (as `URL`s) to the files to upload.  This exists as an optimization so the entire `MediaList` view doesn't have to be redrawn every time an update occurs.
    @Published var paths = [URL]()


    func addFile(_ path: URL) {
        uploadCandinates[path] = UploadCandinate(path)
        paths.append(path)
    }

    func removeFile(_ path: URL) {
        uploadCandinates.removeValue(forKey: path)
        paths.remove(at: paths.firstIndex(of: path)!)
    }


    //    // hike data never changes, so no need to mark it as @Published
    //    var hikes: [Hike] = load("hikeData.json")
}
