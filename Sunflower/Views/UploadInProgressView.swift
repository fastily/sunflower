import SwiftUI

/// The view that gets shown in a sheet when the user starts an upload
struct UploadInProgressView: View {
    
    /// The globally shared model data between views
    @EnvironmentObject var modelData: ModelData
    
    /// The presentation mode environment variable, can be used to dismiss this `View` when embedded in a sheet
    @Environment(\.presentationMode) var presentationMode
    
    /// The main body of the View
    var body: some View {
        VStack {
            Text("Upload In Progress")
                .font(.title)
                .padding(.bottom, 25)
            
            ProgressView(value: modelData.uploadState.currFileProgress)
            Text("Uploading '\(modelData.uploadState.currentFileName)'")
                .padding(.bottom)
            
            ProgressView(value: modelData.uploadState.totalProgress)
            Text("Overall Progress")
                .padding(.bottom, 25)
            
            Button("Cancel Upload") {
                modelData.currentUploadTask?.cancel()
                UIUtils.dismissSheet(presentationMode)
            }
        }
        .padding(25)
        .frame(minWidth: 500, minHeight: 300)
    }
}

struct UploadInProgressView_Previews: PreviewProvider {
    
    /// Creates a  `ModelData` with a pre-configured dummy data in its`UploadState`
    /// - Returns: A `ModelData` object with pre-configured dummy data in its`UploadState`
    private static func makeDummyModelData() -> ModelData {
        let m = ModelData()
        m.uploadState = UploadState(currentFileName: "Example.png", totalProgress: 0.8, currFileProgress: 0.5)
        return m
    }
    
    static var previews: some View {
        UploadInProgressView()
            .previewLayout(.fixed(width: 500, height: 300))
            .environmentObject(makeDummyModelData())
    }
}
