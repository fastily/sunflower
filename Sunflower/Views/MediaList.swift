import SwiftUI

struct MediaList: View {
    
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Configure")) {
                    NavigationLink(destination: GlobalDesc()) {
                        HStack {
                            Image("Example")
                                .resizable()
                                .scaledToFill()
                                .frame(width:50, height:50)
                                .foregroundColor(.blue)
                            
                            Text("Global Upload Settings")
                                .font(.headline)
                                .padding(.leading, 10)
                                
                        }
                        .padding()
                    }
                    
                }
                
                Section(header: Text("Media Files")) {
                    NavigationLink(destination: FileDesc(f: $modelData.fl[0])) {
                        
                        MediaRow(f:Media(isUploaded:true))
                    }
                    //                    MediaRow(f:Media(isUploaded:true))
                    //                    MediaRow(f:Media(isUploaded:true))
                    //                    MediaRow(f:Media(isUploaded:true))
                    //                    MediaRow(f:Media(isUploaded:true))
                }
            }
            .frame(minWidth:300)
        }
        
        
            
    }
    
    
}

struct MediaList_Previews: PreviewProvider {
    static var previews: some View {
        MediaList()
            .environmentObject(ModelData())
            .frame(minWidth: 1000, minHeight: 600)
    }
}
