import SwiftUI

struct GlobalDesc: View {
    
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        UploadForm(d: $modelData.globalDesc)
        //        .onAppear {
        //            d = modelData.globalDesc
        //        }
            .navigationTitle("Global Upload Settings")
            .padding(30)
    }
}

struct GlobalDesc_Previews: PreviewProvider {
    
    
    static var previews: some View {
        GlobalDesc()
            .environmentObject(ModelData())
            .frame(minWidth: 900, minHeight: 500)
    }
}
