import SwiftUI

struct FileDescView: View {
    //@Environment(\.presentationMode) var presentation
    
    @EnvironmentObject var modelData: ModelData
    
    @State private var showFileSheet = false
    
    @State private var wasDeleted = false
    
    var uploadCandinate: UploadCandinate
    
    var body: some View {
        
        if !wasDeleted {
            ScrollView {
            UploadFormView(d: uploadCandinate.details)
                .navigationTitle("Details for \(uploadCandinate.path.lastPathComponent)")
                .padding(30)
                .sheet(isPresented: $showFileSheet) {
                    FileViewerView(uploadCandinate: uploadCandinate)
                }
                .toolbar {

                    // button - view file
                    Button(action: {
                        showFileSheet = true
                    }) {
                        Label("View Image", systemImage: "eye")
                    }
                    .help("View file")

                    // button - unstage file from upload
                    Button(action: {
                        modelData.removeFile(uploadCandinate.path)
                        wasDeleted = true
                        //self.presentation.wrappedValue.dismiss()
                    }) {
                        Label("Remove", systemImage: "x.circle.fill")
                    }
                    .help("Remove this file from the upload")

                }
            }
            .frame(minHeight:600)
        }
        
    }
}


struct FileDescView_Previews: PreviewProvider {
    static var previews: some View {
        FileDescView(uploadCandinate: UploadCandinate(URL(string: "file:///Example.jpg")!))
            .frame(minWidth: 900, minHeight: 500)
    }
}
