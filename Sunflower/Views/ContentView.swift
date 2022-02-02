import SwiftUI

/// Top level wrapper for the main UI View
struct ContentView: View {
    var body: some View {
        MediaList()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
