import SwiftUI

struct MediaRow: View {
    
    @Binding var f: Media
    
    var body: some View {
        HStack {
            f.thumb
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            
            Text(f.name)
                .padding(.leading, 10)
            
            Spacer()
            
            if f.isUploaded {
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
    static var previews: some View {
        Group {
            MediaRow(f: .constant(Media(path: URL(string: "file:///Example.jpg")!)))
            MediaRow(f: .constant(Media(isUploaded: true, path: URL(string: "file:///Example.jpg")!)))
        }
        .previewLayout(.fixed(width: 300, height: 70))
        
    }
}
