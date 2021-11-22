import AppKit
import SwiftUI

struct MediaList: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State private var selectedMedia: UploadStatus?
    
    @State private var isShowingEmptyView = false
    
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
                
                // remove elements
//                Button(action: {
//                    if let sm = selectedMedia {
//
//                        print("Here!")
//
//                        modelData.ulStatus.removeAll {
//                            $0.path == sm.path
//                        }
//
//                        modelData.ml.removeValue(forKey: sm.path)
//
//                        print("Removed \(sm.path)")
//
//                        selectedMedia = nil
//                        isShowingEmptyView = true
////                        print("selected media is \(selectedMedia)")
//                    }
//
//
//                    print("now here!")
//
//                }) {
//                    Label("Remove", systemImage: "trash")
//                }
                
                Spacer()
                
                // start upload
                Button(action: {
                    print("Upload")
                }) {
                    Label("Add", systemImage: "play.fill")
                }
                
                
            }
            
            if modelData.ml.isEmpty {
                Text("Click [+] to add media")
            }
            
//            NavigationLink(destination: Text("Second View"), isActive: $isShowingEmptyView) { EmptyView() }
            
            //                .toolbar {
            //
            //                    Button(action: {
            //                        print("Trash clicked 2")
            //                    }) {
            //                        Label("Remove", systemImage: "trash")
            //                    }
            //                }
            
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
