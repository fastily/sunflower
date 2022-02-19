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
    private static let chunkSize = 1024 * 1024 * 1

    /// The base API endpoint to target
    //    private static let endpoint = "https://commons.wikimedia.org/w/api.php"
    private static let endpoint = "https://en.wikipedia.org/w/api.php"

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

        if let jo = await postAction("login", ["lgname": username, "lgpassword": password, "lgtoken": loginToken], false) {

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


    /// Upload a file via the MediaWiki API
    /// - Parameters:
    ///   - path: The path to the file to upload
    ///   - title: The title to upload the file to (do not include namespace)
    ///   - desc: The text to put on the file description page
    ///   - modelData: The shared `ModelData` to use for updating upload status
    /// - Returns: `true` if the upload was successful
    func upload(_ path: URL, _ title: String, _ desc: String, _ modelData: ModelData) async -> Bool {

        guard let f = try? FileHandle(forReadingFrom: path), let fsize = try? path.resourceValues(forKeys:[.fileSizeKey]).fileSize else {
            return false
        }

        log.info("Uploading '\(path)' to '\(title)'")

        let totalChunks = fsize / Wiki.chunkSize + 1
        var pl = makePL("upload", ["filename": title, "offset": "0", "ignorewarnings": "1", "filesize": String(fsize), "stash": "1"], true)
        var chunkCount = 0
        var filekey = ""

        while let buffer = try? f.read(upToCount: Wiki.chunkSize), !buffer.isEmpty {
            var chunkWasUploaded = false

            for errCount in 0..<5 {
                log.info("Uploading chunk \(chunkCount+1) of \(totalChunks) from \(path)")

                if let r = try? await AF.upload(multipartFormData: { multipartFormData in
                    // The file chunk
                    multipartFormData.append(buffer, withName: "chunk", fileName: path.lastPathComponent, mimeType: "multipart/form-data")

                    // Standard parameters
                    for (k, v) in pl {
                        multipartFormData.append(Data(v.utf8), withName: k)
                    }
                }, to: Wiki.endpoint, method: .post).serializingData().value, let jo = try? JSON(data: r) {

                    let result = jo["upload"]

                    // check for chunk errors
                    if !["Success", "Continue"].contains(result["result"].string) {
                        log.warning("Chunk was not uploaded successfully, server responded with \(result, privacy: .public)")
                        continue
                    }

                    // chunk was successfully uploaded
                    chunkCount += 1
                    filekey = result["filekey"].string!
                    pl["filekey"] = filekey
                    pl["offset"] = String(Wiki.chunkSize * chunkCount)
                    chunkWasUploaded = true
                    break
                }
                else { // probably encountered server error, retry
                    log.info("Encountered error while uploading, this was \(errCount)/5")
                }
            }

            // if failed to upload a chunk after retries, abort
            if !chunkWasUploaded {
                log.error("Exceeded error threshold, abort upload of \(path)")
                try? f.close()
                return false
            }

            // update upload status in model
            let currFileProgress =  Double(chunkCount)/Double(totalChunks)
            await MainActor.run {
                modelData.uploadState.currFileProgress = currFileProgress
            }
        }

        // close local file descriptor & unstash on server
        try? f.close()
        if let jo = await postAction("upload", ["filename": title, "text": desc, "comment": "test 12345", "filekey": filekey, "ignorewarnings": "1"]), let result = jo["upload", "result"].string { //Uploaded with Sunflower \(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)
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

        if let jo = await basicQuery(pl), let token = jo["query", "tokens", prefix + "token"].string {
            return token
        }

        return "+\\"
    }


    ///  Fetches the list of file types that can be uploaded to Commons.  Called automatically by the initializer when this object is created.  See `valid_file_exts`.
    private func uploadableFileTypes() async {
        log.info("Fetching a list of acceptable file upload extensions.")

        if let jo = await basicQuery(["meta": "siteinfo", "siprop": "fileextensions"]) {
            self.valid_file_exts = Array(Set(jo["query", "fileextensions"].arrayValue.map { UTType(filenameExtension: $0["ext"].string!)! }))
        }
    }


    /// Checks if the session derived from the locally stored cookies is still valid.  If it is, configure this `Wiki` as logged in.
    /// - Returns: `true` if the session is valid
    func validateCredentials() async -> Bool {
        csrfToken = await fetchToken()

        if csrfToken != "+\\", let jo = await basicQuery(["meta": "userinfo"]) {
            username = jo["query", "userinfo", "name"].string ?? ""

            return true
        }

        return false
    }


    // MARK: - CONVENIENCE FUNCTIONS

    /// Performs a simple `action` (write) action via the API.
    /// - Parameters:
    ///   - action: The API action to perform
    ///   - params: The parameters to pass to the API (excluding the `defaultParams`, which will be added automatically)
    ///   - applyToken: Set `true` to add the csrf token to the request parameters
    /// - Returns: `JSON` containing the results of this request, or `nil` if something went wrong
    private func postAction(_ action: String, _ params: [String:String] = [:], _ applyToken: Bool = true) async -> JSON? {
        await basicRequest(action: action, params: params, method: .post, applyToken: applyToken)
    }

    /// Performs a simple `query` (read) action via the API.
    /// - Parameter params: The parameters to pass to the API (excluding the `defaultParams`, which will be added automatically)
    /// - Returns: `JSON` containing the results of this request, or `nil` if something went wrong
    private func basicQuery(_ params: [String:String] = [:]) async -> JSON? {
        await basicRequest(action: "query", params: params)
    }

    /// Performs a basic HTTP request to the API.
    /// - Parameters:
    ///   - action: The API action to perform
    ///   - params: Parameters to pass to the API (excluding the `defaultParams`, which will be added automatically)
    ///   - method: The HTTP method to use to perform the request
    ///   - applyToken: Set `true` to add the csrf token to the request parameters
    /// - Returns: `JSON` containing the results of this request, or `nil` if something went wrong
    private func basicRequest(action: String, params: [String:String] = [:], method: HTTPMethod = .get, applyToken: Bool = false) async -> JSON? {
        if let v =  try? await AF.request(Wiki.endpoint, method: method, parameters: makePL(action, params, applyToken)).serializingData().value, let jo = try? JSON(data: v) {
            return jo
        }

        return nil
    }


    /// Convenience method, creates a new parameter list based on the specified action and the default parameters
    /// - Parameters:
    ///   - action: The API action to perform
    ///   - params: The dictionary to merge with the default parameters
    ///   - applyToken: Set `true` to add the csrf token to the request parameters
    /// - Returns: A new `Dictionary` with the default parameters and the specified parameters
    private func makePL(_ action: String, _ params: [String:String] = [:], _ applyToken: Bool = false) -> [String:String] {
        var d = Wiki.defaultParams.merging(params) {(c, _) in c}
        d["action"] = action

        if applyToken {
            d["token"] = csrfToken
        }

        return d
    }
}
