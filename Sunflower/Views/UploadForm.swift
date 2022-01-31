import SwiftUI


/// Represents an upload form.  Doesn't do much by itself, should embed this in another View.
struct UploadForm: View {

    /// The `Desc` object backing the fields in this View
    @ObservedObject var d: Desc

    /// Flag inidicating if the title field should be shown.
    var showTitleField = true
    
    var body: some View {
        
        Form {
            if showTitleField {
                Section(header: Text("Title")) {
                    TextField("", text:$d.title)
                }
            }
            
            Section(header: Text("Description")) {
                TextEditor(text: $d.desc)
                    .frame(minHeight: 50, alignment: .leading)
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
        UploadForm(d: Desc())
            .frame(minWidth: 900, minHeight: 500)
        
    }
}
