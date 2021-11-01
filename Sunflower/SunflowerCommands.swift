import SwiftUI

struct SunflowerCommands: Commands {
    
    private struct MenuContent: View {
        
//        // use the FocusedBinding property wrapper to track the currently selected landmark.  Note that this just reads the value, it must be set/written elsewhere (e.g. in the ListView) in another file before this does anything.
//        @FocusedBinding(\.selectedLandmark) var selectedLandmark

        var body: some View {
            
            Text("placeholder")
        }
    }
    
    
    var body: some Commands { // simillar to View, but reqiures Commands instead of View
        SidebarCommands()
        
        CommandMenu("Landmark") {
            MenuContent()
        }
    }
}
