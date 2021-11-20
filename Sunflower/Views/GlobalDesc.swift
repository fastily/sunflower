import AppKit
import SwiftUI

struct GlobalDesc: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        
        ScrollView {
            UploadForm(d: modelData.globalDesc, showTitleField: false)
                .padding()
            
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
                NSApp.mainWindow?.endSheet(NSApp.keyWindow!) // workaround SwiftUI to show dismiss animation
                
            }.keyboardShortcut(.defaultAction)
        }
        .frame(minWidth:800, minHeight:400)
        .padding()
        .navigationTitle("Edit Global Description")
        
    }
}

struct GlobalDesc_Previews: PreviewProvider {
    static var previews: some View {
        GlobalDesc()
            .environmentObject(ModelData())
            .frame(minWidth: 900, minHeight: 500)
    }
}
