import SwiftUI
import UniformTypeIdentifiers

/// Represents the a file for upload in the List sidebar.  Can show the status of whether the file has been uploaded or not.
struct MediaRowView: View {

    /// The `UploadCandinate` associated with this media row
    @ObservedObject var uploadCandinate: UploadCandinate

    /// The main body of the View
    var body: some View {
        HStack {
            ZStack(alignment: .bottomTrailing) {
                ThumbView(uploadCandinate: uploadCandinate)

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
}


/// Represents the thumbnail icon for the `MediaRowView`.  This view is separate so the image doesn't get repeatedly redrawn.
fileprivate struct ThumbView: View {

    /// The `UploadCandinate` this view is associated with
    let uploadCandinate: UploadCandinate

    /// The main body of the View
    var body: some View {
        if let rawThumb = uploadCandinate.thumbnail {
            Image(decorative: rawThumb, scale: 1.0)
                .mediaRowModifier()
        }
        else {
            let ext = UTType(filenameExtension: uploadCandinate.path.pathExtension)!
            Image("sunflower-\(ext.conforms(to: .audiovisualContent) || ext.conforms(to: .audio) ? "media" : "generic")")
                .mediaRowModifier()
        }
    }
}


/// Creates a status icon with the specified parameters
/// - Parameters:
///   - name: The system name of the icon to use
///   - color: The color to use
/// - Returns: The image containing a status icon
fileprivate func makeStatusIcon(_ name: String, _ color: Color) -> some View {
    Image(systemName: name)
        .foregroundColor(color)
        .font(.title2)
        .background(.white)
        .clipShape(Circle())
}


extension Image {

    /// Shared modifier settings for resizing a sidebar row.  Here's to hoping that SwiftUI allows using `Image` with `ViewModifier` in the future
    /// - Returns: The Image with appropriate settings for the sidebar row.
    func mediaRowModifier() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 55, height: 55)
            .cornerRadius(10)
    }
}


struct MediaRowView_Previews: PreviewProvider {

    /// Convenience function.  Creates an `UploadCandinate` with the specified upload status.
    /// - Parameters:
    ///   - status: The `Status` to create the `UploadCandinate` with
    ///   - path: The path to an example file to upload
    /// - Returns: The newly created `UploadCandinate`
    static private func makeUploadCandinate(_ status: Status = .standby, path: String = "file:///Example.jpg") -> UploadCandinate {
        let c = UploadCandinate(URL(string: path)!)
        c.uploadStatus = status

        return c
    }
    
    static var previews: some View {
        Group {
            MediaRowView(uploadCandinate: makeUploadCandinate(path: "file:///Example.mp3"))
            MediaRowView(uploadCandinate: makeUploadCandinate())
            MediaRowView(uploadCandinate: makeUploadCandinate(.success))
            MediaRowView(uploadCandinate: makeUploadCandinate(.error))
        }
        .previewLayout(.fixed(width: 500, height: 80))
    }
}
