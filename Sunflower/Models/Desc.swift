import Foundation

/// Represents a file description page for a file to be uploaded
struct Desc: Equatable {

    /// The title to upload the image with.  Do not include `File:` prefix.
    var title = ""

    /// The text to put in the `description` parameter of the `Information` template on the file description page.
    var desc = ""

    /// The text to put in the `source` parameter of the `Information` template on the file description page.
    var source = ""

    /// The text to put in the `date` parameter of the `Information` template on the file description page.
    var date = ""

    /// The text to put in the `author` parameter of the `Information` template on the file description page.
    var author = ""

    /// The text to put in the `permission` parameter of the `Information` template on the file description page.
    var permission = ""

    /// The text to use as the categories on the description page
    var cat = ""

    /// The text to use in the license section of the file decription page
    var lic = ""


    /// Convenience method, removes leading & trailing whitespace for the input String
    /// - Parameter s: The String to trim
    /// - Returns: A copy of `s` with leading & trailing whitespace removed
    private static func trim(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Convenience method, clear this form
    mutating func clear() {
        title = ""
        desc = ""
        source = ""
        date = ""
        author = ""
        permission = ""
        cat = ""
        lic = ""
    }

    /// Formats the fields of this object in preparation for uploading.
    mutating func formatForUpload() {
        // remove leading/trailing whitespace
        title = Desc.trim(title)
        desc = Desc.trim(desc)
        source = Desc.trim(source)
        date = Desc.trim(date)
        author = Desc.trim(author)
        permission = Desc.trim(permission)
        cat = Desc.trim(cat)
        lic = Desc.trim(lic)

        // remove File: prefix
        if title.lowercased().hasPrefix("file:") {
            title = String(title[title.index(title.startIndex, offsetBy: 5)...])
        }

    }
}
