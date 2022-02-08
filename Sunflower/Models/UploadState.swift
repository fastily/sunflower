import Foundation

/// Tracks the status of any upload in progress
struct UploadState {
    
    /// The current filename being uploaded
    var currentFileName = ""
    
    /// The current total progress.  Should be a value between 0 and 1
    var totalProgress = 0.0
    
    
    /// The current progress for hte file being uploaded.  Shoudl be a value between 0 and 1.
    var currFileProgress = 0.0
    
    /// Resets the values in this struct to their defaults.
    mutating func reset() {
        currentFileName = ""
        totalProgress = 0.0
        currFileProgress = 0.0
    }
}
