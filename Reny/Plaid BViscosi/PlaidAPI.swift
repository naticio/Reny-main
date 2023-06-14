import Foundation
import Firebase
import FirebaseFunctions
import LinkKit

class PlaidAPI: ObservableObject {
    @Published var hasLoaded = false
    @Published var vc: ViewController = ViewController()
    //@Binding var accessTokenObtained : Bool
    //@EnvironmentObject var model: ContentModel
    
    
}

extension PlaidAPI {
    //PROD
    func getTokenFromCloud(completion: @escaping (String?) -> ()){
        Functions.functions().httpsCallable("createPlaidLinkToken").call { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return completion(nil)
            }
            guard let linkToken = result?.data as? String else {
                return completion(nil)
            }
            completion(linkToken)
        }
    }
    
    
    func setToken(){
        getTokenFromCloud { (linkToken) in
            guard let linkToken = linkToken , !linkToken.isEmpty else { return }
            DispatchQueue.main.async {
                self.vc.setToken(token: linkToken)
                self.hasLoaded = true
            }
        }

    }
    

}


