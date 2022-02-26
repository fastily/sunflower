import SwiftUI

/// The main UI window that gets shown to the user
struct MediaListView: View {
    
    /// The globally shared model data between views
    @EnvironmentObject var modelData: ModelData
    
    /// The currently selected file (via the sidebar) to show the file description editing interface
    @State private var selectedMedia: URL?

    /// Flag indicating if the login form is currently being shown to the user
    @State private var showingLogin = false

    /// Flag indicating if the global description form is currently being shown to the user
    @State private var showingGlobalDesc = false

    /// Flag indicating if the upload in progress screen is currently being shown to the user
    @State private var showingUploadInProgress = false

    /// Flag indicating if the preflight check error alert is currently being shown to the user
    @State private var showingPreflightCheckError = false

    /// The message to show to the user if there was a preflight check error
    @State private var preflightErrorMessage = ""

    /// Flag indicating if nothing is selected in the sidebar.  This controls the default message shown in the detail view.
    @State private var nothingIsSelected = true

    /// The main body of the View
    var body: some View {
        NavigationView {

            ZStack {
                List(selection: $selectedMedia) {
                    Section(header: Text("Files to Upload")) {

                        ForEach(modelData.paths, id: \.self) { path in
                            NavigationLink(destination: { FileDescView(uploadCandinate: modelData.uploadCandinates[path]!) }, label: {
                                MediaRowView(uploadCandinate: modelData.uploadCandinates[path]!)
                            })
                            .tag(path)
                        }

                    }
                    .collapsible(false)
                }
                .onDeleteCommand {
                    if let selection = selectedMedia {
                        modelData.removeFile(selection)
                        selectedMedia = nil
                        nothingIsSelected = true
                    }
                }
                .frame(minWidth: 350)
                .toolbar {

                    // button - add file dialog
                    Button(action: {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = true
                        panel.allowedContentTypes = modelData.wiki.valid_file_exts

                        if panel.runModal() == .OK {
                            for u in panel.urls {
                                modelData.addFile(u)
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
                            // TODO: sanity check titles
                            if let errMsg = UploadUtils.preflightCheck(modelData) {
                                preflightErrorMessage = "\(errMsg).  Please fix this before proceeding."
                                showingPreflightCheckError = true
                            }
                            else {
                                modelData.uploadState.reset()
                                showingUploadInProgress = true

                                modelData.currentUploadTask = Task {
                                    await UploadUtils.performUploads(modelData)
                                    showingUploadInProgress = false
                                }
                            }

                        }) {
                            Label("Upload", systemImage: "play.fill")
                        }
                        .disabled(modelData.paths.isEmpty)
                        .sheet(isPresented: $showingUploadInProgress) {
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

                NavigationLink(destination: NothingSelectedView(), isActive: $nothingIsSelected) { EmptyView() }.opacity(0)
            }
        }
        .frame(minWidth: 1000, minHeight: 600)
    }
}

fileprivate struct NothingSelectedView: View {

    /// The globally shared model data between views
    @EnvironmentObject var modelData: ModelData

    /// The main body of the View
    var body: some View {
        Text(modelData.paths.isEmpty ? "Click [+] to add media": "Click a file in the sidebar to edit its description")
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
