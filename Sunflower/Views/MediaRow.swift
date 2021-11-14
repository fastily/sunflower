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
            
            if uploadStatus.isUploaded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            else {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .padding()
    }
}

struct MediaRow_Previews: PreviewProvider {
    
    private static var p = URL(string: "file:///Example.jpg")!
    
    static var previews: some View {
        Group {
            MediaRow(f: Media(path: p), uploadStatus: UploadStatus(p))
//            MediaRow(f: Media(path: URL(string: "file:///Example.jpg")!, uploadStatus: UploadStatus())
        }
        .previewLayout(.fixed(width: 300, height: 70))
        
    }
}
