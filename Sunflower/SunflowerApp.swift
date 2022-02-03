import SwiftUI


/// Main driver, entry point
@main struct SunflowerApp: App {

    /// The globally shared model data between views
    @StateObject private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
        .commands {
            SunflowerCommands()
        }
    }
}
