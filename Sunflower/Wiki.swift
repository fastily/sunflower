import Alamofire
import Foundation
import SwiftyJSON
import UniformTypeIdentifiers


/// General Wiki-interfacing functionality and config data
class Wiki {

    /// Default request parameters which will always be sent to the API
    private static let defaultParams = ["format": "json", "formatversion" : "2"]

    /// The maximum size (in bytes) of each chunk to upload when uploading files
    private static let chunkSize = 1024 * 1024 * 4

    /// The base API endpoint to target
    private let endpoint = "https://commons.wikimedia.org/w/api.php"

    /// The username the user is currently logged in as
    var username = ""

    /// Indiciates if the user is currently logged in.  Will be set automatically by `login()`
    var isLoggedIn = false

    /// The user's CSRF token
    private var csrfToken = "+\\"

    /// The list of file extensions which can be uploaded to Commons
    var valid_file_exts = [UTType]()


    /// Initializer, creates a new Wiki object
    init() {
        uploadableFileTypes()
    }


    // MARK: - ACTIONS

    /// Logs the user into Sunflower with the specified credentials
    /// - Parameters:
    ///   - username: The username to use
    ///   - password: The password to use
    ///   - completion: The callback to run post-login.  Will be passed the result of the login.  If `true`, then the login was successful.
    func login(_ username: String, _ password: String, completion: @escaping (Bool) -> ()) {
        fetchToken(getCSRF: false) { loginToken in

            self.basicRequest("login", ["lgname": username, "lgpassword": password, "lgtoken": loginToken], .post).responseData { loginResponse in
                let jo = self.extractJO(loginResponse)["login"]

                if jo["result"].string != "Success" {
                    completion(false)
                    return
                }

                self.username = jo["lgusername"].string!

                self.fetchToken(getCSRF: true) { csrfToken in
                    self.csrfToken = csrfToken
                }

                completion(true)
            }
        }
    }


    func upload(_ path: URL, _ title: String, _ desc: String = "", _ summary: String = "", completion: @escaping (Bool) -> ()) {

        //let size = try? FileManager.default.attributesOfItem(atPath: path.path)[.size] as? Int
        if let f = try? FileHandle(forReadingFrom: path), let size = try? path.resourceValues(forKeys:[.fileSizeKey]).fileSize {
            uploadHelper(path.lastPathComponent, f, 0, size / Wiki.chunkSize + 1, makePL("upload", ["filename": title, "offset": "0", "ignorewarnings": "1", "filesize": String(size), "token": csrfToken, "stash": "1"]), title, desc, summary, completion)
        }
        else {
            completion(false)
        }
    }

    private func uploadHelper(_ localName: String, _ f: FileHandle, _ chunkCount: Int, _ totalChunks: Int, _ pl: [String:String], _ title: String, _ desc: String, _ summary: String, _ completion: @escaping (Bool) -> ()) {

        guard let buffer = try? f.read(upToCount: Wiki.chunkSize) else {
            completion(false)
            return
        }

        if buffer.isEmpty {
            unstash(pl, title, desc, summary, completion)
            return
        }

        AF.upload(multipartFormData: { multipartFormData in
            // Standard parameters
            for (k, v) in pl {
                multipartFormData.append(Data(v.utf8), withName: k)
            }

            // The file chunk
            multipartFormData.append(buffer, withName: "chunk", fileName: localName, mimeType: "multipart/form-data")
        }, to: endpoint).responseData { r in

            let jo = self.extractJO(r)["upload"]

            // check for chunk errors
            if !["Success", "Continue"].contains(jo["result"].string) {
                completion(false)
                return // TODO: Echo out the error
            }

            let newChunkCount = chunkCount + 1
            var newPL = pl
            newPL["filekey"] = jo["filekey"].string
            newPL["offest"] = String(Wiki.chunkSize * chunkCount)

            self.uploadHelper(localName, f, newChunkCount, totalChunks, newPL, title, desc, summary, completion)
        }
    }


    private func unstash(_ pl: [String:String], _ title: String, _ desc: String, _ summary: String, _ completion: @escaping (Bool) -> ()) {
        basicRequest("upload", ["filename": title, "text": desc, "comment": summary, "filekey": pl["filekey"]!, "ignorewarnings": "1"]).responseData { r in
            completion(self.extractJO(r)["upload", "result"].string == "Success")
        }
    }




    // MARK: - QUERIES

    /// Fetches a login or csrf token from the API
    /// - Parameters:
    ///   - getCSRF: set `true` to fetch a csrf token, or `false` to get a login token.
    ///   - completion: The callback function to run.  Will be passed the token that was retrieved from the API as a `String`.
    func fetchToken(getCSRF: Bool, completion: @escaping (String) -> ()) {
        var pl = ["meta": "tokens"]
        if !getCSRF {
            pl["type"] = "login"
        }
        let prefix = pl["type", default: "csrf"]

        basicRequest("query", pl).responseData {
            completion(self.extractJO($0)["query", "tokens", prefix + "token"].string ?? "+\\")
        }
    }


    ///  Fetches the list of file types that can be uploaded to Commons.  Called automatically by the initializer when this object is created.  See `valid_file_exts`.
    private func uploadableFileTypes() {
        basicRequest("query", ["meta": "siteinfo", "siprop": "fileextensions"]).responseData { r in
            self.valid_file_exts = Array(Set(self.extractJO(r)["query", "fileextensions"].arrayValue.map { UTType(filenameExtension: $0["ext"].string!)! }))
        }
    }



    // MARK: - CONVENIENCE FUNCTIONS

    /// Convenience method, performs a basic HTTP request to the API
    /// - Parameters:
    ///   - action: The API action to perform
    ///   - params: Parameters to pass to the API (excluding the `defaultParams`, which will be added automatically)
    ///   - method: The HTTP method to use to perform the request
    /// - Returns: A `DataRequest` with the results of this request
    private func basicRequest(_ action: String, _ params: [String:String] = [:], _ method: HTTPMethod = .get) -> DataRequest {
        return AF.request(self.endpoint, method: method, parameters: makePL(action, params))
    }


    /// Convenience method, extracts a `JSON` object from the specified http response
    /// - Parameter r: The response from the server
    /// - Returns: A `JSON` object with the response from the server.  Returns an empty `JSON` object otherwise.
    private func extractJO(_ r: AFDataResponse<Data>) -> JSON {
        if let v = r.value, let jo = try? JSON(data: v) {
            return jo
        }

        return JSON()
    }

    /// Convenience method, creates a new parameter list based on the specified action and the default parameters
    /// - Parameters:
    ///   - action: The API action to perform
    ///   - params: The dictionary to merge with the default parameters
    /// - Returns: A new `Dictionary` with the default parameters and the specified parameters
    private func makePL(_ action: String, _ params: [String:String] = [:]) -> [String:String] {
        var d = Wiki.defaultParams.merging(params) {(c, _) in c}
        d["action"] = action
        return d
    }
}
