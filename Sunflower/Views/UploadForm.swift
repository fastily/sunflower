import SwiftUI

struct UploadForm: View {
    
    @Binding var d: Desc
    
    var body: some View {
        Form {
            Section(header: Text("Description")) {
                TextEditor(text: $d.desc)
            }
            
            Section(header: Text("Source")) {
                TextField("", text:$d.source)
            }
            
            Section(header: Text("Date")) {
                TextField("", text:$d.date)
            }
            
            Section(header: Text("Author")) {
                TextField("", text:$d.author)
            }
            
            Section(header: Text("Permission")) {
                TextField("", text:$d.permission)
            }
            
            Section(header: Text("Licensing")) {
                TextField("", text:$d.lic)
            }
            
            Section(header: Text("Categories")) {
                TextField("", text:$d.cat)
            }
        }
    }
}

struct UploadForm_Previews: PreviewProvider {
    static var previews: some View {
        UploadForm(d: .constant(Desc()))
    }
}
