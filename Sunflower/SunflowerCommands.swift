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

//        CommandMenu("Account") {
//            MenuContent(modelData: modelData)
//        }
    }
}


//fileprivate struct MenuContent: View {
//
//    var modelData: ModelData
//
//    //        // use the FocusedBinding property wrapper to track the currently selected landmark.  Note that this just reads the value, it must be set/written elsewhere (e.g. in the ListView) in another file before this does anything.
//    //        @FocusedBinding(\.selectedLandmark) var selectedLandmark
//
//    var body: some View {
//
//        Text("Login/Logout")
//    }
//}
