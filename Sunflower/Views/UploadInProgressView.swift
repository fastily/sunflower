import SwiftUI


/// The view that gets shown in a sheet when the user starts an upload
struct UploadInProgressView: View {

    /// The globally shared model data between views
    @EnvironmentObject var modelData: ModelData

    /// The presentation mode environment variable, can be used to dismiss this `View` when embedded in a sheet
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Upload In Progress")
                .font(.title)
                .padding(.bottom)

            ProgressView(value: modelData.uploadState.currFileProgress)
            Text(modelData.uploadState.currentFileName)
                .padding(.bottom)

            ProgressView(value:modelData.uploadState.totalProgress)
            Text("Overall Progress")
                .padding(.bottom, 25)

            Button("Cancel Upload") {
                dismissSheet()
            }
        }
        .padding(25)
        .frame(minWidth: 500, minHeight: 300)
    }

    /// Convenience function, dismiss this view
    private func dismissSheet() {
        presentationMode.wrappedValue.dismiss()
        NSApp.mainWindow?.endSheet(NSApp.keyWindow!) // workaround SwiftUI to show dismiss animation
    }
}

struct UploadInProgressView_Previews: PreviewProvider {
    static var previews: some View {
        UploadInProgressView()
            .previewLayout(.fixed(width: 500, height: 300))
    }
}
