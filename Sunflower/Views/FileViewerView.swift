import SwiftUI

/// Represents a simple image preview window
struct FileViewerView: View {

    /// The presentation mode environment variable, can be used to dismiss this `View` when embedded in a sheet
    @Environment(\.presentationMode) var presentationMode

    /// The `UploadCandinate` associated with this `View`
    var uploadCandinate: UploadCandinate

    /// The main body of the View
    var body: some View {
        VStack {
            if FileManager.default.fileExists(atPath: uploadCandinate.path.path), let rawThumb = UIUtils.downsample(uploadCandinate.path, 750) {
                Image(decorative: rawThumb, scale: 1.0)
                    .resizable()
                    .aspectRatio( contentMode: .fit)
                    .padding(.bottom)
            }
            else {
                Text("Encountered error while generating preview")
            }

            Button("Done") {
                UIUtils.dismissSheet(presentationMode)
            }.keyboardShortcut(.defaultAction)
        }
        .padding()
        .frame(maxWidth: 800, maxHeight: 800)
    }
}

struct FileViewerView_Previews: PreviewProvider {
    static var previews: some View {
        FileViewerView(uploadCandinate: UploadCandinate(URL(string: "file:///Example.jpg")!))
    }
}

