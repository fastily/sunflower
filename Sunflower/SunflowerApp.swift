import SwiftUI

/// Main driver, entry point
@main struct SunflowerApp: App {

    /// The globally shared model data between views
    @StateObject private var modelData = ModelData()

    /// The main body of the Scene
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .commands {
            SunflowerCommands(modelData: modelData)
        }
    }
}
