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
            Section(header: makeSectionHeader("Title")) {
                TextField("", text:$d.title)
                    .padding(.bottom)
            }
            
            Section(header: makeSectionHeader("Description")) {
                TextEditor(text: $d.desc)
                    .frame(minHeight: 30, alignment: .leading)
                    .padding(.bottom)
            }
            
            Section(header: makeSectionHeader("Source")) {
                TextField("", text:$d.source)
                    .padding(.bottom)
            }
            
            Section(header: makeSectionHeader("Date")) {
                TextField("", text:$d.date)
                    .padding(.bottom)
            }
            
            Section(header: makeSectionHeader("Author")) {
                TextField("", text:$d.author)
                    .padding(.bottom)
            }
            
            Section(header: makeSectionHeader("Permission")) {
                TextField("", text:$d.permission)
                    .padding(.bottom)
            }
            
            Section(header: makeSectionHeader("Licensing")) {
                TextEditor(text: $d.lic)
                    .frame(minHeight: 30, alignment: .leading)
                    .padding(.bottom)
            }
            
            Section(header: makeSectionHeader("Categories")) {
                TextEditor(text: $d.cat)
                    .frame(minHeight: 30, alignment: .leading)
                    .padding(.bottom)
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
            .frame(minWidth: 900, minHeight: 650)
        
    }
}
