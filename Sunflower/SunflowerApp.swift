import SwiftUI

@main
struct SunflowerApp: App {
    
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
