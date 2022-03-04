import SwiftUI

/// The menubar menus for Sunflower
struct SunflowerCommands: Commands {

    /// The globally shared model data between views
    @ObservedObject var modelData: ModelData

    /// The main body of the View
    var body: some Commands {
        SidebarCommands()

        CommandGroup(after: CommandGroupPlacement.appVisibility) {
            Divider()
            Button("Logout\(modelData.isLoggedIn ? " " : "")\(modelData.wiki.username)") {
                Task {
                    modelData.isLoggedIn = await !modelData.wiki.logout()
                }
            }
            .disabled(!modelData.isLoggedIn)
        }

        CommandGroup(after: CommandGroupPlacement.textEditing) {
            Button("Clear Global Config") {
                modelData.globalDesc.clear()
            }

            Divider()

            Button("Remove All Files") {
                if !modelData.uploadIsInProgress {
                    modelData.currSelectedFile = nil
                    modelData.removeAllFiles()
                }
            }

            Button("Remove Uploaded Files") {
                if !modelData.uploadIsInProgress {
                    modelData.currSelectedFile = nil
                    modelData.uploadCandinates.filter { $1.uploadStatus == .success }.keys.forEach { modelData.removeFile($0) }
                }
            }

        }
    }
}
