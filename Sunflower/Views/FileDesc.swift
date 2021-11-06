import SwiftUI

struct FileDesc: View {
    @State var f: Media
    
    var body: some View {
        
        UploadForm(d: $f.details)
            .navigationTitle("Details for \(f.name)")
            .padding(30)
    }
}

struct FileDesc_Previews: PreviewProvider {
    static var previews: some View {
        FileDesc(f: Media(path: URL(string: "file:///Example.jpg")!))
            .frame(minWidth: 900, minHeight: 500)
    }
}
