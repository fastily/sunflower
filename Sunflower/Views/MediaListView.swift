import SwiftUI

/// The main UI window that gets shown to the user
struct MediaListView: View {
    
    /// The globally shared model data between views
    @EnvironmentObject var modelData: ModelData
    
    /// Flag indicating if the login form is currently being shown to the user
    @State private var showingLogin = false
    
    /// Flag indicating if the global description form is currently being shown to the user
    @State private var showingGlobalDesc = false
    
    /// Flag indicating if the preflight check error alert is currently being shown to the user
    @State private var showingPreflightCheckError = false
    
    /// The message to show to the user if there was a preflight check error
    @State private var preflightErrorMessage = ""
    
    /// The main body of the View
    var body: some View {
        NavigationView {
            
            List(selection: $modelData.currSelectedFile) {
                Section(header: Text("Files to Upload")) {
                    
                    ForEach(modelData.paths, id: \.self) { path in
                        MediaRowView(uploadCandinate: modelData.uploadCandinates[path]!)
                            .tag(path)
                    }
                    
                }
                .collapsible(false)
            }
            .onDeleteCommand {
                if let selection = modelData.currSelectedFile {
                    modelData.removeFile(selection)
                    modelData.currSelectedFile = nil
                }
            }
            .animation(.default, value: modelData.paths)
            .frame(minWidth: 350)
            .toolbar {
                
                // button - add file dialog
                Button(action: {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = true
                    panel.allowedContentTypes = modelData.wiki.valid_file_exts
                    
                    if panel.runModal() == .OK {
                        for u in panel.urls {
                            if !modelData.paths.contains(u) {
                                modelData.addFile(u)
                            }
                        }
                    }
                }) {
                    Label("Add", systemImage: "plus.app")
                }
                .help("Choose files to upload")
                
                // button - show global config sheet
                Button(action: {
                    showingGlobalDesc = true
                }) {
                    Label("Edit Global Config", systemImage: "doc.badge.gearshape")
                }
                .help("Edit global upload config")
                .sheet(isPresented: $showingGlobalDesc) {
                    GlobalDescView()
                }
                
                Spacer()
                
                if modelData.isLoggedIn {
                    // button - start upload
                    Button(action: {
                        if let errMsg = UploadUtils.preflightCheck(modelData) {
                            preflightErrorMessage = "\(errMsg).  Please fix this before proceeding."
                            showingPreflightCheckError = true
                        }
                        else {
                            let filesToUpload = modelData.paths.filter { modelData.uploadCandinates[$0]!.uploadStatus != .success }
                            if filesToUpload.isEmpty {
                                return
                            }
                            
                            modelData.uploadState.reset()
                            modelData.uploadIsInProgress = true
                            
                            modelData.currentUploadTask = Task {
                                await UploadUtils.performUploads(modelData, filesToUpload)
                                modelData.uploadIsInProgress = false
                            }
                        }
                        
                    }) {
                        Label("Upload", systemImage: "play.fill")
                    }
                    .disabled(modelData.paths.isEmpty)
                    .sheet(isPresented: $modelData.uploadIsInProgress) {
                        UploadInProgressView()
                    }
                    .alert("Error", isPresented: $showingPreflightCheckError, actions: {}) {
                        Text(preflightErrorMessage)
                    }
                    .help("Peform upload")
                }
                else {
                    // button - login
                    Button(action: {
                        showingLogin = true
                    }) {
                        Label("Login", systemImage: "person.crop.circle.badge.questionmark")
                    }
                    .sheet(isPresented: $showingLogin) {
                        LoginView()
                    }
                    .help("Login to your Wikimedia account")
                }
            }

            DetailView()
        }
        .frame(minWidth: 1000, minHeight: 600)
    }
}


/// Represents the detail view to the right of the sidebar
fileprivate struct DetailView: View {
    
    /// The globally shared model data between views
    @EnvironmentObject var modelData: ModelData
    
    /// The main body of the View
    var body: some View {
        if let selected = modelData.currSelectedFile {
            FileDescView(uploadCandinate: modelData.uploadCandinates[selected]!)
        }
        else {
            Text(modelData.paths.isEmpty ? "Click [+] to add media": "Click a file in the sidebar to edit its description")
        }
    }
}


struct MediaListView_Previews: PreviewProvider {
    
    /// Convenience method, creates an example `ModelData` for previewing
    /// - Returns: The newly created `ModelData` object for previewing
    private static func makeEnvObj() -> ModelData {
        let md = ModelData()
        
        for m in [UploadCandinate(URL(string: "file:///Example.jpg")!), UploadCandinate(URL(string: "file:///Example1.jpg")!)] {
            md.uploadCandinates[m.path] = m
            md.paths.append(m.path)
        }
        
        return md
    }
    
    static var previews: some View {
        Group {
            MediaListView()
                .environmentObject(makeEnvObj())
            
            MediaListView()
                .environmentObject(ModelData())
        }
    }
}
