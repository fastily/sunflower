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

            Button("Remove All Files") {
                modelData.paths.removeAll()
                modelData.uploadCandinates.removeAll()
            }

        }
    }

}
