import AppKit
import SwiftUI

struct MediaList: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State private var selectedMedia: UploadStatus?
    
    @State private var isShowingEmptyView = false
    
    @State private var showingPopover = false

    @State private var showingLogin = false

    var body: some View {
        
        NavigationView {
            VStack {
                List(selection: $selectedMedia) {
                    
                    Section(header: Text("Files to Upload")) {
                        ForEach(modelData.ulStatus, id: \.path) { uploadStatus in
                            NavigationLink(destination: FileDesc(f: modelData.ml[uploadStatus.path]!)) {
                                MediaRow(f: modelData.ml[uploadStatus.path]!, uploadStatus: uploadStatus)
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
                    
                    if panel.runModal() == .OK {
                        //                        modelData.fl.append(contentsOf: panel.urls.map { Media(path: $0) })
                        
                        for u in panel.urls {
                            modelData.ml[u] = Media(path: u)
                        }
                        
                        modelData.ulStatus.append(contentsOf: panel.urls.map { UploadStatus($0) })
                        
                        print(modelData.ulStatus)
                        
                    }
                }) {
                    Label("Add", systemImage: "plus.app")
                }
                
                Spacer()
                
                // start upload
                
                switch(modelData.mainButtonState){
                case .notLoggedIn:
                    Button(action: {
//                        print("Login")
                        print(HTTPCookieStorage.shared.cookies!)
                        _ = Wiki().login("Fastily", "lol")
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
                        
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle())
//                            .scaleEffect(0.5)
                        //                            .frame(width: 20, height: 20)
                        //                        Label("Login", systemImage: "person.crop.circle.badge.questionmark")
                    }
                }
            }
            
            if modelData.ml.isEmpty {
                Text("Click [+] to add media")
            }
            
            
        }
        .frame(minWidth: 1000, minHeight: 600)
    }
}

struct MediaList_Previews: PreviewProvider {
    
    private static var envObj: ModelData {
        let md = ModelData()
        
        for m in [Media(path: URL(string: "file:///Example.jpg")!), Media(path: URL(string: "file:///Example1.jpg")!)] {
            md.ml[m.path] = m
            md.ulStatus.append(UploadStatus(m.path))
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
