import AppKit
import SwiftUI

struct MediaList: View {
    
    //    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var modelData: ModelData
    
    @State private var selectedMedia: Media?
    
    var body: some View {
        
        //        ForEach($modelData.ulStatus, id: \.path) { $u in
        //
        //            if let $m = $modelData.ml[u.path, default:Media(path: URL(string: "file:///Example.jpg")!)] {
        //                NavigationLink(destination: FileDesc(f: $m)) {
        //                    //                MediaRow(f: $u)
        //                    //                    .tag(u)
        //                    EmptyView()
        //                }
        //            }
        //        }
        
        
        NavigationView {
            VStack {
//                if modelData.ml.isEmpty {
//                    Text("Click the [+] icon to add media")
//                }
//                else {
                    List(selection: $selectedMedia) {
                        
                        Section(header: Text("Files to Upload")) {
                            
                            ForEach(modelData.ulStatus, id: \.path) { uploadStatus in
                                NavigationLink(destination: FileDesc(f: modelData.ml[uploadStatus.path]!)) {
                                    MediaRow(f: modelData.ml[uploadStatus.path]!, uploadStatus: uploadStatus)
                                        .tag(uploadStatus)
                                }
                            }
                            
                        }
                    }
                    .id(UUID())
                    .padding(.bottom)
                    .overlay(BottomSidebarView(), alignment: .bottom)
//                }
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
                Button(action: {
                    print("Trash clicked")
                }) {
                    Label("Remove", systemImage: "trash")
                }
                
                Spacer()
                
                // start upload
                Button(action: {
                    print("Upload")
                }) {
                    Label("Add", systemImage: "play.fill")
                }
                
                
            }
            
            Text("Click [+] to add media")
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
