import AppKit
import SwiftUI

struct MediaList: View {
    
    @EnvironmentObject var modelData: ModelData

    @State private var selectedMedia: URL?
    
    @State private var isShowingEmptyView = false
    
    @State private var showingPopover = false

    @State private var showingLogin = false

    var body: some View {

        VStack {
            NavigationView {
                VStack {
                    List(selection: $selectedMedia) {

                        Section(header: Text("Files to Upload")) {

                            ForEach(modelData.paths, id: \.self) { uploadStatus in
                                NavigationLink(destination: FileDesc(f: modelData.uploadCandinates[uploadStatus]!)) {
                                    MediaRow(uploadCandinate: modelData.uploadCandinates[uploadStatus]!)
                                }
                                .tag(uploadStatus)
                            }
                        }
                        .collapsible(false)

                    }

                    //                .id(UUID())
                    .padding(.bottom)
                    .overlay(BottomSidebarView(), alignment: .bottom)
                }
                .frame(minWidth: 350)
                .toolbar {

                    // add files
                    Button(action: {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = true
                        panel.allowedContentTypes = modelData.wiki.valid_file_exts

                        if panel.runModal() == .OK {
                            //                        modelData.fl.append(contentsOf: panel.urls.map { Media(path: $0) })

                            for u in panel.urls {
                                modelData.addFile(u)
                                print(u)
//                                modelData.ml[u] = Media(path: u)
                            }

//                            modelData.ulStatus.append(contentsOf: panel.urls.map { UploadStatus($0) })
                            print(modelData.paths)

                        }
                    }) {
                        Label("Add", systemImage: "plus.app")
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
                    case .standby:
                        Button(action: {
                            print("Upload")
                        }) {
                            Label("Upload", systemImage: "play.fill")
                        }
                    case .inProgress:
                        Button(action: {
                            print("In Progress")
                            showingPopover = true
                        }) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.5)
                                .popover(isPresented: $showingPopover) {
                                    VStack {
                                        Text("Your content here")
                                            .font(.headline)
                                            .padding(.bottom)
                                        ProgressView(value: 0.5)
                                    }
                                    .padding()
                                }
                        }
                    }
                }

                if modelData.paths.isEmpty {
                    Text("Click [+] to add media")
                }
            }

            Divider()
            Text("Hello, World!")
//                .background(.secondary)
                .padding()

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
