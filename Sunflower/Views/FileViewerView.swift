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
            UploadManager.downsampleImage(uploadCandinate.path, to: CGSize(width: 750, height: 750))
                .resizable()
                .aspectRatio( contentMode: .fit)
                .padding(.bottom)

            Button("Done") {
                presentationMode.wrappedValue.dismiss()
                NSApp.mainWindow?.endSheet(NSApp.keyWindow!) // workaround SwiftUI to show dismiss animation
                
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

