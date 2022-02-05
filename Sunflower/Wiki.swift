import Alamofire
import Foundation
import os
import SwiftyJSON
import UniformTypeIdentifiers


/// General Wiki-interfacing functionality and config data
class Wiki {

    /// Default request parameters which will always be sent to the API
    private static let defaultParams = ["format": "json", "formatversion" : "2"]

    /// The maximum size (in bytes) of each chunk to upload when uploading files
    private static let chunkSize = 1024 * 1024 * 4

    /// The base API endpoint to target
    private static let endpoint = "https://commons.wikimedia.org/w/api.php"

    /// The logger associated with this Wiki
    private let log = Logger()

    /// The username the user is currently logged in as
    var username = ""

    /// The user's CSRF token
    private var csrfToken = "+\\"

    /// The list of file extensions which can be uploaded to Commons
    var valid_file_exts = [UTType]()


    /// Initializer, creates a new Wiki object
    init() {
        Task {
            await uploadableFileTypes()
        }
    }


    // MARK: - ACTIONS

    /// Logs the user into Sunflower with the specified credentials
    /// - Parameters:
    ///   - username: The username to use
    ///   - password: The password to use
    func login(_ username: String, _ password: String) async -> Bool {

        let loginToken = await fetchToken(getCSRF: false)

        if let jo = await basicRequest("login", ["lgname": username, "lgpassword": password, "lgtoken": loginToken], .post) {

            let result = jo["login"]

            if result["result"].string == "Success" {
                self.username = result["lgusername"].string!
                csrfToken = await fetchToken()

                print(csrfToken)

                return true
            }
        }

        return false
    }


    func upload(_ path: URL, _ title: String, _ desc: String = "", _ summary: String = "") async -> Bool {

        guard let f = try? FileHandle(forReadingFrom: path), let fsize = try? path.resourceValues(forKeys:[.fileSizeKey]).fileSize else {
            return false
        }

        log.info("Uploading '\(path)' to '\(title)'")

        let totalChunks = fsize / Wiki.chunkSize + 1
        var pl = ["filename": title, "offset": "0", "ignorewarnings": "1", "filesize": String(fsize), "token": csrfToken, "stash": "1"]
        var chunkCount = 0
        var filekey = ""

        while let buffer = try? f.read(upToCount: Wiki.chunkSize), !buffer.isEmpty {
            var chunkWasUploaded = false

            for errCount in 0..<5 {
                log.info("Uploading chunk \(chunkCount+1) of \(totalChunks) from \(path)")

                if let r = try? await AF.upload(multipartFormData: { multipartFormData in
                    // Standard parameters
                    for (k, v) in pl {
                        multipartFormData.append(Data(v.utf8), withName: k)
                    }

                    // The file chunk
                    multipartFormData.append(buffer, withName: "chunk", fileName: path.lastPathComponent, mimeType: "multipart/form-data")
                }, to: Wiki.endpoint).serializingData().value, let jo = try? JSON(data: r) {

                    let result = jo["upload"]

                    // check for chunk errors
                    if !["Success", "Continue"].contains(result["result"].string) {
                        log.warning("Chunk was not uploaded successfully, server responded with \(result, privacy: .public)")
                        continue
                    }

                    chunkCount += 1
                    filekey = result["filekey"].string!
                    pl["filekey"] = filekey
                    pl["offset"] = String(Wiki.chunkSize * chunkCount)

                    chunkWasUploaded = true
                    break
                }
                else {
                    log.info("Encountered error while uploading, this was \(errCount)/5")
                }
            }

            if !chunkWasUploaded {
                log.error("Exceeded error threshold, abort upload of \(path)")
                try? f.close()
                return false
            }
        }

        try? f.close()

        if let jo = await basicRequest("upload", ["filename": title, "text": desc, "comment": summary, "filekey": filekey, "ignorewarnings": "1"], .post), let result = jo["upload", "result"].string {
            return result == "Success"
        }

        return false
    }

    // MARK: - QUERIES

    /// Fetches a login or csrf token from the API
    /// - Parameters:
    ///   - getCSRF: set `true` to fetch a csrf token, or `false` to get a login token.
    func fetchToken(getCSRF: Bool = true) async -> String {
        var pl = ["meta": "tokens"]
        if !getCSRF {
            pl["type"] = "login"
        }
        let prefix = pl["type", default: "csrf"]

        log.debug("Fetching \(prefix) token...")

        if let jo = await basicRequest("query", pl), let token = jo["query", "tokens", prefix + "token"].string {
            return token
        }

        return "+\\"
    }


    ///  Fetches the list of file types that can be uploaded to Commons.  Called automatically by the initializer when this object is created.  See `valid_file_exts`.
    private func uploadableFileTypes() async {
        log.info("Fetching a list of acceptable file upload extensions.")

        if let jo = await basicRequest("query", ["meta": "siteinfo", "siprop": "fileextensions"]) {
            self.valid_file_exts = Array(Set(jo["query", "fileextensions"].arrayValue.map { UTType(filenameExtension: $0["ext"].string!)! }))
        }
    }

    func validateCredentials() async -> Bool {
        csrfToken = await fetchToken()

        if csrfToken != "+\\", let jo = await basicRequest("query", ["meta": "userinfo"]) {
            username = jo["query", "userinfo", "name"].string ?? ""

            return true
        }

        return false
    }


    // MARK: - CONVENIENCE FUNCTIONS

    /// Convenience method, performs a basic HTTP request to the API
    /// - Parameters:
    ///   - action: The API action to perform
    ///   - params: Parameters to pass to the API (excluding the `defaultParams`, which will be added automatically)
    ///   - method: The HTTP method to use to perform the request
    /// - Returns: A `DataRequest` with the results of this request
    private func basicRequest(_ action: String, _ params: [String:String] = [:], _ method: HTTPMethod = .get) async -> JSON? {
        if let v =  try? await AF.request(Wiki.endpoint, method: method, parameters: makePL(action, params)).serializingData().value, let jo = try? JSON(data: v) {
            return jo
        }

        return nil
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
