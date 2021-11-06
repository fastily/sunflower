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
                Label("Create Event", systemImage: "calendar.badge.plus")
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
        
        
        NavigationView {
            Group {
                if modelData.fl.isEmpty {
                    Text("Click the [ + ] icon to add media")
                    
                }
                else {
                    List(selection: $selectedMedia) {
                        
                        Section(header: Text("Files to Upload")) {
                            ForEach($modelData.fl) { $m in
                                NavigationLink(destination: FileDesc(f: m)) {
                                    MediaRow(f: $m)
                                        .tag(m)
                                }
                            }
                        }
                    }
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
                        modelData.fl.append(contentsOf: panel.urls.map { url in
                            Media(path: url)
                        })
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
                Media(isUploaded: true, path: URL(string: "file:///Example.jpg")!)
            ]))
    }
}
