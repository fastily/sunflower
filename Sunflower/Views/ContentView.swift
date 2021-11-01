import SwiftUI

struct ContentView: View {
    var body: some View {
        MediaList()
            .frame(minWidth: 1000, minHeight: 600)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
