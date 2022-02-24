import SwiftUI


/// Represents a file description page form
struct FileDescView: View {
    
    /// The shared model data object
    @EnvironmentObject var modelData: ModelData
    
    /// Indicates if the sheet for previewing the file is open.  Currently restricted to jpg/png files
    @State private var showFileSheet = false
    
    /// The `UploadCandinate` associated with this file description form
    var uploadCandinate: UploadCandinate
    
    /// The main body of the View
    var body: some View {
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
                        if UploadUtils.isDisplayableFile(uploadCandinate.path) {
                            showFileSheet = true
                        }
                        else {
                            NSWorkspace.shared.activateFileViewerSelecting([uploadCandinate.path])
                        }
                    }) {
                        Label("View Image", systemImage: "eye")
                    }
                    .help("View file")
                }
            
        }
        .frame(minHeight:600)
    }
}


struct FileDescView_Previews: PreviewProvider {
    static var previews: some View {
        FileDescView(uploadCandinate: UploadCandinate(URL(string: "file:///Example.jpg")!))
            .frame(minWidth: 900, minHeight: 500)
    }
}
