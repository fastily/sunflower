import SwiftUI

struct BottomSidebarView: View {
    
    @State private var showingGlobalConfig = false
    
    var body: some View {
        VStack {
            Divider()
            
            Button(action: {
                showingGlobalConfig = true
            }) {
                Label("Edit Global Config", systemImage: "doc.badge.gearshape")
            }
            .buttonStyle(PlainButtonStyle()) // show plain buttons for macOS
            .padding(.bottom, 5)
            .foregroundColor(.blue)
            .sheet(isPresented: $showingGlobalConfig) {
                GlobalDesc()
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct BottomSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSidebarView()
    }
}
