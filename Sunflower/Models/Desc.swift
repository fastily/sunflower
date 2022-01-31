import Foundation

/// Represents a file description page for a file to be uploaded
class Desc: ObservableObject {
    @Published var title = ""
    @Published var desc = ""
    @Published var source = ""
    @Published var date = ""
    @Published var author = "~~~~"
    @Published var permission = ""
    @Published var cat = ""
    @Published var lic = ""
}
