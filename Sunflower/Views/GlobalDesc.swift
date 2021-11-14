import AppKit
import SwiftUI

struct GlobalDesc: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        
        UploadForm(d: modelData.globalDesc, showTitleField: false)
            .navigationTitle("Global Upload Settings")
        //                .padding(.leading, 30)
        //                .padding(.top, 30)
            .padding(30)
            .frame(minWidth:800, minHeight:600)
        
        Button("Done") {
            //            DataController.shared.saveHypedEvent(hypedEvent: hypedEvent)
            presentationMode.wrappedValue.dismiss()
            NSApp.mainWindow?.endSheet(NSApp.keyWindow!) // workaround SwiftUI to show dismiss animation
            
        }.keyboardShortcut(.defaultAction)
        
    }
}

struct GlobalDesc_Previews: PreviewProvider {
    
    
    static var previews: some View {
        GlobalDesc()
            .environmentObject(ModelData())
            .frame(minWidth: 900, minHeight: 500)
    }
}
