import SwiftUI

@main
struct SunflowerApp: App {
    
    @StateObject private var modelData = ModelData() // use @StateObject to initialize this model once during lifetime of the App
    
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
