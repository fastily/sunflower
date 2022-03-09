import SwiftUI

/// Form which represents the global title and description
struct GlobalDescView: View {
    
    /// The presentation mode environment variable, can be used to dismiss this `View` when embedded in a sheet
    @Environment(\.presentationMode) var presentationMode
    
    /// The shared model data object
    @EnvironmentObject var modelData: ModelData
    
    /// The main body of the View
    var body: some View {
        
        ScrollView {
            UploadFormView(d: $modelData.globalDesc)
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
