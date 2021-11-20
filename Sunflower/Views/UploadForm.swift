import SwiftUI

struct UploadForm: View {
    
    @ObservedObject var d: Desc
    
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
                //                        .textFieldStyle(PlainTextFieldStyle())
                    .frame(minHeight: 50, alignment: .leading)
                //                        .background(Color(NSColor.underPageBackgroundColor))
                //                        .opacity(0.9)
                
                //                    static let background = Color(NSColor.windowBackgroundColor)
                //                    static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
                //                    static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
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
