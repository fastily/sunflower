import SwiftUI

/// Represents an upload form.  Doesn't do much by itself, should embed this in another View.
struct UploadFormView: View {

    /// The `Desc` object backing the fields in this View
    @State private var d: Desc

    /// The function that gets called whenever the user edits the text of this form.  Should be used to save the value of the form fields.
    private var saveResult: (Desc) -> ()

    /// Initializer, creates a new `UploadFormView`.
    /// - Parameters:
    ///   - d: The `Desc` to populate this form's fields with
    ///   - saveResult: The function to call whenever the user edits the text of this form.
    init(_ d: Desc, _ saveResult: @escaping (Desc) -> ()) {
        self.d = d
        self.saveResult = saveResult
    }

    /// The main body of the View
    var body: some View {

        Form {
            TFView(title: "Title", binding: $d.title)
            TEView(title: "Description", binding: $d.desc)
            TFView(title: "Source", binding: $d.source)
            TFView(title: "Date", binding: $d.date)
            TFView(title: "Author", binding: $d.author)
            TFView(title: "Permission", binding: $d.permission)
            TEView(title: "Licensing", binding: $d.lic)
            TEView(title: "Categories", binding: $d.cat)
        }
        .onChange(of: d) { newVal in
            saveResult(newVal)
        }
    }
}


/// Represents a single-line form field for use in an upload form
fileprivate struct TFView: View {

    /// Tthe label to show next to the field
    var title: String

    /// The variable backing this field
    @Binding var binding: String

    /// The main body of the View
    var body: some View {
        Section(header: makeSectionHeader(title)) {
            TextField("", text: $binding)
                .padding(.bottom)
        }
    }
}

/// Represents a multi-line form field for use in an upload form
fileprivate struct TEView: View {

    /// Tthe label to show next to the field
    var title: String

    /// The variable backing this field
    @Binding var binding: String

    /// The main body of the View
    var body: some View {
        Section(header: makeSectionHeader(title)) {
            TextEditor(text: $binding)
                .frame(minHeight: 30, alignment: .leading)
                .padding(.bottom)
        }
    }
}


/// Convenience function, creates a section header with the specified `String`.
/// - Parameter s: The `String` to use for the section header
/// - Returns: The section header
fileprivate func makeSectionHeader(_ s: String) -> Text {
    Text(s).font(.headline)
}

struct UploadFormView_Previews: PreviewProvider {
    static var previews: some View {
        UploadFormView(Desc(), { _ in })
            .frame(minWidth: 900, minHeight: 650)
        
    }
}
