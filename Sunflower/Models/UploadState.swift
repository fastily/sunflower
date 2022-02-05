import Foundation

/// Tracks the status of any upload in progress
class UploadState: ObservableObject {

    /// The current filename being uploaded
    @Published var currentFileName = ""

    @Published var totalProgress = 0.0

    @Published var currFileProgress = 0.0

    @Published var inProgress = false


    func reset() {
        currentFileName = ""
        totalProgress = 0.0
        currFileProgress = 0.0
        inProgress = false
    }
}
