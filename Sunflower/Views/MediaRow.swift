import SwiftUI

struct MediaRow: View {
    
    var f: Media
    
    @ObservedObject var uploadStatus: UploadStatus
    
    var body: some View {
        LazyHStack {
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
                EmptyView()
            case .success:
                makeImg("checkmark.circle.fill", .green)
            case .error:
                makeImg("x.circle.fill", .red)
            }
        }
        .padding()
    }
    
    func makeImg(_ name: String, _ color: Color) -> some View {
        Image(systemName: name)
            .foregroundColor(color)
            .font(.title2)
    }
    
}

struct MediaRow_Previews: PreviewProvider {
    
    private static var p = URL(string: "file:///Example.jpg")!
    
    static var previews: some View {
        Group {
            MediaRow(f: Media(path: p), uploadStatus: UploadStatus(p))
            MediaRow(f: Media(path: p), uploadStatus: UploadStatus(p, .success))
            MediaRow(f: Media(path: p), uploadStatus: UploadStatus(p, .error))
        }
        .previewLayout(.fixed(width: 300, height: 70))
        
    }
}
