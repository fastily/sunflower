import SwiftUI

struct MediaRow: View {
    
    var f: Media
    
    var body: some View {
        HStack {
            f.thumb
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            VStack(alignment:.leading) {
                Text("Example.jpg")
                    .font(.headline)

            }
            
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
            MediaRow(f: Media())
            MediaRow(f:Media(isUploaded: true))
        }
        .previewLayout(.fixed(width: 300, height: 70))
        
    }
}
