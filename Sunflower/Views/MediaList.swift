import SwiftUI

/// The main UI window that gets shown to the user
struct MediaList: View {

    /// The globally shared model data between views
    @EnvironmentObject var modelData: ModelData

    /// The currently selected file (via the sidebar) to show the file description editing interface
    @State private var selectedMedia: URL?

    @State private var showingLogin = false

    @State private var showingGlobalDesc = false

    @State private var showingUploadInProgress = false

    var body: some View {
        NavigationView {
            VStack {
                List(selection: $selectedMedia) {

                    Section(header: Text("Files to Upload")) {
                        ForEach(modelData.paths, id: \.self) { path in
                            NavigationLink(destination: FileDesc(uploadCandinate: modelData.uploadCandinates[path]!)) {
                                MediaRow(uploadCandinate: modelData.uploadCandinates[path]!)
                            }
                            .tag(path)
                        }
                    }
                    .collapsible(false)

                }

                //                .id(UUID())
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

                        print(modelData.paths)
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
                    GlobalDesc()
                }

                Spacer()

                if modelData.isLoggedIn {
                    // button - start upload
                    Button(action: {
                        showingUploadInProgress = true
                    }) {
                        Label("Upload", systemImage: "play.fill")
                    }
                    .sheet(isPresented: $showingUploadInProgress) {
                        UploadInProgressView()
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
                        Login()
                    }
                    .help("Login to your Wikimedia account")
                }
            }

            if modelData.paths.isEmpty {
                Text("Click [+] to add media")
            }
        }
        .frame(minWidth: 1000, minHeight: 600)
    }
}

struct MediaList_Previews: PreviewProvider {
    
    private static var envObj: ModelData {
        let md = ModelData()
        
        for m in [UploadCandinate(URL(string: "file:///Example.jpg")!), UploadCandinate(URL(string: "file:///Example1.jpg")!)] {
            md.uploadCandinates[m.path] = m
            md.paths.append(m.path)
        }
        
        return md
    }
    
    static var previews: some View {
        Group {
            MediaList()
                .environmentObject(envObj)
            
            MediaList()
                .environmentObject(ModelData())
        }
    }
}
