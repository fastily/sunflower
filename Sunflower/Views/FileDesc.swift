import SwiftUI

struct FileDesc: View {
    //    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var modelData: ModelData
    
    @State private var showFileSheet = false
    
    @State private var wasDeleted = false
    
    var f: UploadCandinate
    
    var body: some View {
        
        if !wasDeleted {
            UploadForm(d: f.details)
                .navigationTitle("Details for \(f.path.lastPathComponent)")
                .padding(30)
                .sheet(isPresented: $showFileSheet) {
                    FileViewer(f: f)
                }
                .toolbar {
                    Button(action: {
                        modelData.removeFile(f.path)

                        print("Trash clicked 3")
                        wasDeleted = true
                        //                    self.presentation.wrappedValue.dismiss()
                    }) {
                        Label("Remove", systemImage: "trash")
                    }
                    

                    Button(action: {
                        showFileSheet = true
                    }) {
                        Label("View Image", systemImage: "eye")
                    }
                }
        }
        
    }
}


struct FileDesc_Previews: PreviewProvider {
    static var previews: some View {
        FileDesc(f: UploadCandinate(URL(string: "file:///Example.jpg")!))
            .frame(minWidth: 900, minHeight: 500)
    }
}
