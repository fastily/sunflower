import SwiftUI

/// Top level wrapper for the main UI View
struct ContentView: View {

    /// The globally shared model data between views
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        MediaListView()
            .onAppear {
                Task {
                    modelData.isLoggedIn = await modelData.wiki.validateCredentials()
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
