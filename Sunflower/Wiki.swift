import Alamofire
import Foundation
import SwiftyJSON


/// General Wiki-interfacing functionality and config data
class Wiki {

    /// Default request parameters which will always be sent to the API
    private static let defaultParams = ["format": "json", "formatversion" : "2"]

    /// The hostname of the wiki to target
    let domain: String
    
    let endpoint: String
    
    var username = ""

    var isLoggedIn = false

    var csrfToken = "+\\"

    /// Initializer, creates a new Wiki object
    /// - Parameter domain: the hostname of the wiki to target
    init(_ domain: String = "commons.wikimedia.org") {
        self.domain = domain
        self.endpoint = "https://\(domain)/w/api.php"
    }


    /// Convenience method, performs a basic HTTP request to the API
    /// - Parameters:
    ///   - action: The API action to perform
    ///   - params: Parameters to pass to the API (excluding the `defaultParams`, which will be added automatically)
    ///   - method: The HTTP method to use to perform the request
    /// - Returns: A `DataRequest` with the results of this request
    private func basicRequest(_ action: String, _ params: [String:String] = [:], _ method: HTTPMethod = .get) -> DataRequest {
        return AF.request(self.endpoint, method: method, parameters: makePL(action, params))
    }


    /// Logs the user into Sunflower with the specified credentials
    /// - Parameters:
    ///   - username: The username to use
    ///   - password: The password to use
    ///   - completion: The callback to run post-login.  Will be passed the result of the login.  If `true`, then the login was successful.
    func login(_ username: String, _ password: String, completion: @escaping (Bool) -> ()) {
        fetchToken(getCSRF: false) { loginToken in

//            print("loginToken: \(loginToken)")

            self.basicRequest("login", ["lgname": username, "lgpassword": password, "lgtoken": loginToken], .post).responseData { loginResponse in

                let jo = self.extractJO(loginResponse)["login"]

//                print(jo)

                if jo["result"].string != "Success" {
                    completion(false)
                    return
                }

                self.username = jo["lgusername"].string!

                self.fetchToken(getCSRF: true) { csrfToken in
//                    print("csrfToken: \(csrfToken)")
                    self.csrfToken = csrfToken
                }

                completion(true)
            }
        }
    }



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
