import AppKit
import SwiftUI

struct MediaList: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var modelData: ModelData
    
    @State private var selectedMedia: Media?
    
    @State private var showingGlobalConfig = false
    
    
    var bottomSidebarView: some View {
        VStack {
            Divider()
            
            Button(action: {
                showingGlobalConfig = true
            }) {
                Label("Edit Global Config", systemImage: "doc.badge.gearshape")
            }
            .buttonStyle(PlainButtonStyle()) // show plain buttons for mac
            .padding(.bottom, 5)
            .foregroundColor(.blue)
            .sheet(isPresented: $showingGlobalConfig) {
                GlobalDesc()
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        //        .opacity(1)
    }
    
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
            Group {
                if modelData.ml.isEmpty {
                    Text("Click the [+] icon to add media")
                    
                }
                else {
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
                    .overlay(bottomSidebarView, alignment: .bottom)
                }
            }
            .frame(minWidth:300)
            .toolbar {
                
                // add files
                Button(action: {
                    let panel = NSOpenPanel()
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
        }
        .frame(minWidth: 1000, minHeight: 600)
    }
}

struct MediaList_Previews: PreviewProvider {
    static var previews: some View {
        MediaList()
            .environmentObject(ModelData([
                Media(path: URL(string: "file:///Example.jpg")!),
                Media(path: URL(string: "file:///Example.jpg")!, isUploaded: true)
            ]))
    }
}
