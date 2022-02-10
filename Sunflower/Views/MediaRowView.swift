import SwiftUI

/// Represents the a file for upload in the List sidebar.  Can show the status of whether the file has been uploaded or not.
struct MediaRowView: View {

    /// The `UploadCandinate` associated with this media row
    @ObservedObject var uploadCandinate: UploadCandinate

    /// The main body of the View
    var body: some View {
        LazyHStack {
            ZStack(alignment: .bottomTrailing) {
                UploadUtils.downsampleImage(uploadCandinate.path)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 55, height: 55)
                    .cornerRadius(10)

                switch uploadCandinate.uploadStatus {
                case .standby:
                    EmptyView()
                case .success:
                    makeStatusIcon("checkmark.circle.fill", .green)
                case .error:
                    makeStatusIcon("x.circle.fill", .red)
                }

            }
            
            Text(uploadCandinate.path.lastPathComponent)
                .padding(.leading, 10)
        }
        .padding()
    }


    /// Creates a status icon with the specified parameters
    /// - Parameters:
    ///   - name: The system name of the icon to use
    ///   - color: The color to use
    /// - Returns: The image containing a status icon
    private func makeStatusIcon(_ name: String, _ color: Color) -> some View {
        Image(systemName: name)
            .foregroundColor(color)
            .font(.title2)
            .background(.white)
            .clipShape(Circle())
    }
}


struct MediaRowView_Previews: PreviewProvider {

    /// Convenience function.  Creates an `UploadCandinate` with the specified upload status.
    /// - Parameter status: The `Status` to create the `UploadCandinate` with
    /// - Returns: The newly created `UploadCandinate`
    static private func makeUploadCandinate(_ status: Status = .standby) -> UploadCandinate {
        let c = UploadCandinate(URL(string: "file:///Example.jpg")!)
        c.uploadStatus = status

        return c
    }
    
    static var previews: some View {
        Group {
            MediaRowView(uploadCandinate: makeUploadCandinate())
            MediaRowView(uploadCandinate: makeUploadCandinate(.success))
            MediaRowView(uploadCandinate: makeUploadCandinate(.error))
        }
        .previewLayout(.fixed(width: 500, height: 80))
    }
}
