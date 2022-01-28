//

import Alamofire
import Foundation
import SwiftyJSON




class Wiki {

    /// Default request parameters which will always be sent to the API
    private static let defaultParams = ["format": "json", "formatversion" : "2"]

    /// The hostname of the wiki to target
    let domain: String
    
    let endpoint: String
    
    let username = "<Anonymous>"

    var isLoggedIn = false



    /// Initializer, creates a new Wiki object
    /// - Parameter domain: the hostname of the wiki to target
    init(_ domain: String = "commons.wikimedia.org") {
        self.domain = domain
        
        self.endpoint = "https://\(domain)/w/api.php"
    }




    func login(_ username: String, _ password: String) -> Bool {

        AF.request(self.endpoint, parameters:  makePL("query", ["meta": "tokens", "type": "csrf|login"])).responseData { response in
//            debugPrint(response)

//            if response.result == .

            print("------------\n")
//            print(HTTPCookieStorage.shared.cookies!)

//            let jo: [String:AnyObject] = try! JSONSerialization.jsonObject(with: response.value!, options: .mutableContainers) as! [String: AnyObject]
            let jo = try! JSON(data: response.value!)
            print(jo["query"]["tokens"]["logintoken"])




//            print(jo["query"]["tokens"]["logintoken"])

        }

        return true
    }



    func fetchTokens(_ getCSRF: Bool) -> String {
        return ""
    }

    /// Convenience method, creates a new parameter list based on the specified action and the default parameters
    /// - Parameters:
    ///   - action: The API action to perform
    ///   - params: The dictionary to merge with the default parameters
    /// - Returns: A new Dictionary with the default parameters and the specified parameters
    private func makePL(_ action: String, _ params: [String:String] = [:]) -> [String:String] {
        var d = Wiki.defaultParams.merging(params) {(c, _) in c}
        d["action"] = action
        return d
    }
    
}
