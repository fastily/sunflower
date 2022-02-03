import SwiftUI

/// The main UI window that gets shown to the user
struct MediaList: View {

    /// The globally shared model data between views
    @EnvironmentObject var modelData: ModelData

    /// The currently selected file (via the sidebar) to show the file description editing interface
    @State private var selectedMedia: URL?
    
//    @State private var isShowingEmptyView = false
    
//    @State private var showingPopover = false

    @State private var showingLogin = false

    @State private var showingGlobalDesc = false

    @State private var showingUploadInProgress = false

    var body: some View {
        NavigationView {
            VStack {
                List(selection: $selectedMedia) {

                    Section(header: Text("Files to Upload")) {
                        ForEach(modelData.paths, id: \.self) { uploadStatus in
                            NavigationLink(destination: FileDesc(uploadCandinate: modelData.uploadCandinates[uploadStatus]!)) {
                                MediaRow(uploadCandinate: modelData.uploadCandinates[uploadStatus]!)
                            }
                            .tag(uploadStatus)
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

                // start upload
                switch(modelData.mainButtonState){
                case .notLoggedIn:
                    Button(action: {
                        showingLogin = true
                    }) {
                        Label("Login", systemImage: "person.crop.circle.badge.questionmark")
                    }
                    .sheet(isPresented: $showingLogin) {
                        Login()
                    }
                    .help("Login to your Wikimedia account")

                case .standby:
                    Button(action: {
                        showingUploadInProgress = true
                    }) {
                        Label("Upload", systemImage: "play.fill")
                    }
                    .sheet(isPresented: $showingUploadInProgress) {
                        UploadInProgressView()
                    }
                    .help("Peform upload")

//                case .inProgress:
//                    Button(action: {
//                        print("In Progress")
//                        showingPopover = true
//                    }) {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle())
//                            .scaleEffect(0.5)
//                            .popover(isPresented: $showingPopover) {
//                                VStack {
//                                    Text("Your content here")
//                                        .font(.headline)
//                                        .padding(.bottom)
//                                    ProgressView(value: 0.5)
//                                }
//                                .padding()
//                            }
//                    }
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
