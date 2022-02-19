import AppKit
import SwiftUI

struct GlobalDescView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var modelData: ModelData

    /// The main body of the View
    var body: some View {
        
        ScrollView {
            UploadFormView(d: modelData.globalDesc, showTitleField: false)
                .padding()
            
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
                NSApp.mainWindow?.endSheet(NSApp.keyWindow!) // workaround SwiftUI to show dismiss animation
                
            }.keyboardShortcut(.defaultAction)
        }
        .frame(minWidth:800, minHeight:400, maxHeight: 650)
        .padding()
        .navigationTitle("Edit Global Description")
        
    }
}

struct GlobalDescView_Previews: PreviewProvider {
    static var previews: some View {
        GlobalDescView()
            .environmentObject(ModelData())
            .frame(minWidth: 900, minHeight: 500)
    }
}
