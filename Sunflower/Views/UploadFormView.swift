import SwiftUI


/// Represents an upload form.  Doesn't do much by itself, should embed this in another View.
struct UploadFormView: View {

    /// The `Desc` object backing the fields in this View
    @ObservedObject var d: Desc

    /// Flag inidicating if the title field should be shown.
    var showTitleField = true

    /// The main body of the View
    var body: some View {
        
        Form {
            if showTitleField {
                Section(header: makeSectionHeader("Title")) {
                    TextField("", text:$d.title)
                }
            }
            
            Section(header: makeSectionHeader("Description")) {
                TextEditor(text: $d.desc)
                    .frame(minHeight: 50, alignment: .leading)
            }
            
            Section(header: makeSectionHeader("Source")) {
                TextField("", text:$d.source)
            }
            
            Section(header: makeSectionHeader("Date")) {
                TextField("", text:$d.date)
            }
            
            Section(header: makeSectionHeader("Author")) {
                TextField("", text:$d.author)
            }
            
            Section(header: makeSectionHeader("Permission")) {
                TextField("", text:$d.permission)
            }
            
            Section(header: makeSectionHeader("Licensing")) {
                TextField("", text:$d.lic)
            }
            
            Section(header: makeSectionHeader("Categories")) {
                TextField("", text:$d.cat)
            }
        }
        
    }

    /// Convenience function, creates a section header with the specified `String`.
    /// - Parameter s: The `String` to use for the section header
    /// - Returns: The section header
    private func makeSectionHeader(_ s: String) -> Text {
        Text(s).font(.headline)
    }
}

struct UploadFormView_Previews: PreviewProvider {
    static var previews: some View {
        UploadFormView(d: Desc())
            .frame(minWidth: 900, minHeight: 500)
        
    }
}
