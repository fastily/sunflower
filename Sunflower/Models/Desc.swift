import Foundation

/// Represents a file description page for a file to be uploaded
class Desc: ObservableObject {
    
    /// The title to upload the image with.  Do not include `File:` prefix.
    @Published var title = ""
    
    /// The text to put in the `description` parameter of the `Information` template on the file description page.
    @Published var desc = ""
    
    /// The text to put in the `source` parameter of the `Information` template on the file description page.
    @Published var source = ""
    
    /// The text to put in the `date` parameter of the `Information` template on the file description page.
    @Published var date = ""
    
    /// The text to put in the `author` parameter of the `Information` template on the file description page.
    @Published var author = "~~~"
    
    /// The text to put in the `permission` parameter of the `Information` template on the file description page.
    @Published var permission = ""
    
    /// The text to use as the categories on the description page
    @Published var cat = ""
    
    /// The text to use in the license section of the file decription page
    @Published var lic = ""


    // TODO: merge in global desc

    /// The generated file description page, based on the properties in this `Desc`
    var description: String {
        return """
=={{int:filedesc}}==
{{Information
|description=\(desc)
|date=\(date)
|source=\(source)
|author=\(author)
}}

=={{int:license-header}}==
\(lic)

\(cat)
"""
    }
}
