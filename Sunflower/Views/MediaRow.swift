import SwiftUI

/// Represents the a file for upload in the List sidebar.  Can show the status of whether the file has been uploaded or not.
struct MediaRow: View {

    @ObservedObject var uploadCandinate: UploadCandinate

    var body: some View {
        LazyHStack {
            UploadManager.downsampleImage(uploadCandinate.path)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 55, height: 55)
                .cornerRadius(5)
            
            Text(uploadCandinate.path.lastPathComponent)
                .padding(.leading, 10)
            
            Spacer()
            
            switch uploadCandinate.uploadStatus {
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
            MediaRow(uploadCandinate: makeUploadCandinate())
            MediaRow(uploadCandinate: makeUploadCandinate(.success))
            MediaRow(uploadCandinate: makeUploadCandinate(.error))
        }
        .previewLayout(.fixed(width: 300, height: 70))
        
    }

    /// Convenience function.  Creates an `UploadCandinate` with the specified upload status.
    /// - Parameter status: The `Status` to create the `UploadCandinate` with
    /// - Returns: The newly created `UploadCandinate`
    static private func makeUploadCandinate(_ status: Status = .standby) -> UploadCandinate {
        let c = UploadCandinate(p)
        c.uploadStatus = status

        return c
    }
}
