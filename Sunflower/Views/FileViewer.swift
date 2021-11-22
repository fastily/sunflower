//

import SwiftUI

struct FileViewer: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var f: Media
    
    var body: some View {
        VStack {
            if let img = NSImage(byReferencingFile: f.path.path) {
                
                Image(nsImage: img)
                    .resizable()
                    
                    .aspectRatio( contentMode: .fit)
                    .frame(maxWidth: 800, maxHeight: 800)
                    .padding(.bottom)
                
            } else {
                Image("Example")
            }
            
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
                NSApp.mainWindow?.endSheet(NSApp.keyWindow!) // workaround SwiftUI to show dismiss animation
                
            }.keyboardShortcut(.defaultAction)
        }
        
        
        .padding()
    }
}

struct FileViewer_Previews: PreviewProvider {
    static var previews: some View {
        FileViewer(f: Media(path: URL(string: "file:///Example.jpg")!))
    }
}

