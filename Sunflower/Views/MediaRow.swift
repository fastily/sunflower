import SwiftUI

struct MediaRow: View {
    
//    @Binding var f: Media
    
    var f: Media
    
    @ObservedObject var uploadStatus: UploadStatus
    
    var body: some View {
        HStack {
            f.thumb
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 55, height: 55)
                .cornerRadius(5)
            
            Text(f.name)
                .padding(.leading, 10)
            
            Spacer()
            
            switch uploadStatus.status {
            case .standby:
//                makeImg("checkmark.circle.fill", .green)
                EmptyView()
            case .success:
                makeImg("checkmark.circle.fill", .green)
//            case .uploading:
//                makeImg("clock.fill", .yellow)
            case .error:
                makeImg("x.circle.fill", .red)
            }
            
//            if uploadStatus.isUploaded {
//                Image(systemName: "checkmark.circle.fill")
//                    .foregroundColor(.green)
//            }
//            else {
//                ProgressView()
//                    .scaleEffect(0.7)
//            }
        }
        .padding()
    }
    
    func makeImg(_ name: String, _ color: Color) -> some View {
        Image(systemName: name)
            .foregroundColor(color)
    }
    
}

struct MediaRow_Previews: PreviewProvider {
    
    private static var p = URL(string: "file:///Example.jpg")!
    
    static var previews: some View {
        Group {
            MediaRow(f: Media(path: p), uploadStatus: UploadStatus(p))
//            MediaRow(f: Media(path: p), uploadStatus: UploadStatus(p, .uploading))
            MediaRow(f: Media(path: p), uploadStatus: UploadStatus(p, .success))
            MediaRow(f: Media(path: p), uploadStatus: UploadStatus(p, .error))
//            MediaRow(f: Media(path: URL(string: "file:///Example.jpg")!, uploadStatus: UploadStatus())
        }
        .previewLayout(.fixed(width: 300, height: 70))
        
    }
}
