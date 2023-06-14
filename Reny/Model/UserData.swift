import Foundation
import Firebase
import FirebaseFunctions
import SwiftUI
import FirebaseAuth
import FirebaseStorage

final class UserData: ObservableObject {
    @Published var hasLoaded = false
    @Published var netWorth = 0.0
    @Published var totalSpent = 0.0
    @Published var totalEarned = 0.0
    @Published var transactions: [Transaction] = []
    @Published var spending: [Transaction] = []
    @Published var income: [Transaction] = []
    @Published var spendingByCategory: Dictionary<String, Double> = [String: Double]()
    @Published var incomeByCategory: Dictionary<String, Double> = [String: Double]()
    
    @Published var listingAddress: String = ""
    
    @Published var scenario = ""
    //test commit
}

extension UserData {
    
    func getBalance(){
        self.hasLoaded = false;
        let json: [String: Any] = [
            "accessToken": UserDefaults.standard.value(forKey: "access_token") as! String
        ]
        
        Functions.functions().httpsCallable("getBalance").call(json) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            let accounts = result?.data as! [NSMutableDictionary]
            var netWorth = 0.0
            for account in accounts {
                let balance = account["balances"] as! NSMutableDictionary
                let current = balance["current"] as! Double
                netWorth += current
            }
            self.netWorth = netWorth
//            DispatchQueue.main.async {
//                self.hasLoaded = true;
//                //test
//            }

        }
    }
    
    func getTransactions(){
        
        self.hasLoaded = false;
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        //let firstOfMonth = calendar.date(from: calendar.dateComponents(_: [.year, .month], from: currentDate))
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: currentDate)
        
        //let startDate = dateFormatter.string(from: firstOfMonth!)
        let startDate = dateFormatter.string(from: oneYearAgo!)
        let endDate = dateFormatter.string(from: currentDate)
        
        let json: [String: Any] = [
            "accessToken": UserDefaults.standard.string(forKey: "access_token"),
            "startDate": startDate,
            "endDate": endDate
        ]
        
        Functions.functions().httpsCallable("getTransactions").call(json) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            let items = result?.data as! [NSMutableDictionary]
            self.spending.removeAll()
            self.income.removeAll()
            self.transactions.removeAll()
            for item in items {
                let name = (item["merchant_name"] as! NSObject == NSNull()) ? item["name"] : item["merchant_name"]
                var transaction = Transaction(categories: (item["category"] as! [String]),
                                              name: name as! String,
                                              payment_channel: item["payment_channel"] as! String,
                                              amount: item["amount"] as! Double,
                                              date: item["date"] as! String,
                                              pending: (item["pending"] != nil))
                //debit card purchases are positive; credit card payments, direct deposits, and refunds are negative.
                if ((item["amount"] as! Double) < 0) { //plaid:
                    self.income.append(transaction)
                    self.totalEarned += transaction.amount
                }
                else {
                    var found = false
                    var transfer = false
                    for category in transaction.categories! {
                        if(!found){
                            var sum = transaction.amount
                            if category.contains("Healthcare"){
                                transaction.category = .Healthcare;
                                sum += self.spendingByCategory["Healthcare"] ?? 0
                                self.spendingByCategory.updateValue(_: sum, forKey: "Healthcare")
                                found = true
                            }
                            else if category.contains("Recreation"){
                                transaction.category = .Recreation;
                                sum += self.spendingByCategory["Recreation"] ?? 0
                                self.spendingByCategory.updateValue(_: sum, forKey: "Recreation")
                                found = true
                                
                            }
                            else if category.contains("Shops"){
                                transaction.category = .Shopping;
                                sum += self.spendingByCategory["Shops"] ?? 0
                                self.spendingByCategory.updateValue(_: sum, forKey: "Shops")
                                found = true
                                
                            }
                            else if category.contains("Personal Care"){
                                transaction.category = .PersonalCare;
                                sum += self.spendingByCategory["PersonalCare"] ?? 0
                                self.spendingByCategory.updateValue(_: sum, forKey: "PersonalCare")
                                found = true
                                
                            }
                            else if category.contains("Home Improvement"){
                                transaction.category = .HomeImprovement;
                                sum += self.spendingByCategory["HomeImprovement"] ?? 0
                                self.spendingByCategory.updateValue(_: sum, forKey: "HomeImprovement")
                                found = true
                                
                            }
                            else if category.contains("Travel"){
                                transaction.category = .Travel;
                                sum += self.spendingByCategory["Travel"] ?? 0
                                self.spendingByCategory.updateValue(_: sum, forKey: "Travel")
                                found = true
                                
                            }
                            else if category.contains("Auto"){
                                transaction.category = .Auto;
                                sum += self.spendingByCategory["Auto"] ?? 0
                                self.spendingByCategory.updateValue(_: sum, forKey: "Auto")
                                found = true
                                
                            }
                            else if category.contains("Food"){
                                transaction.category = .Food;
                                sum += self.spendingByCategory["Food"] ?? 0
                                self.spendingByCategory.updateValue(_: sum, forKey: "Food")
                                found = true
                                
                            }
                            else if category.contains("Credit Card"){
                                transaction.category = .CC;
                                sum += self.spendingByCategory["Credit Card"] ?? 0
                                self.spendingByCategory.updateValue(_: sum, forKey: "Credit Card")
                                found = true
                            }
                            else if category.contains("Transfer") {
                                transfer = true
                            }
                        }
                    }
                    if !found && !transfer {
                        transaction.category = .Miscellaneous
                        var sum = self.spendingByCategory["Miscellaneous"] ?? 0
                        sum += transaction.amount
                        self.spendingByCategory.updateValue(_: sum, forKey: "Miscellaneous")
                    }
                    if !transfer{
                        self.spending.append(transaction)
                        self.transactions.append(transaction)
                        self.totalSpent += transaction.amount
                    }
                }
            }
            DispatchQueue.main.async {
                self.hasLoaded = true;
            }
            
            //save to UserDefaults
            //UserDefaults.standard.set(, forKey: "Phone") //saved previously
            UserDefaults.standard.set("NAME to be defined", forKey: "Name")
            UserDefaults.standard.set(self.totalEarned, forKey: "total_earnings")
            UserDefaults.standard.set(self.totalSpent, forKey: "total_spending")
            UserDefaults.standard.set(self.listingAddress, forKey: "address")
            UserDefaults.standard.set(Date(), forKey: "submitted_date")
            UserDefaults.standard.set(Date(), forKey: "plaid_exec_date")
            UserDefaults.standard.set("Pending Application", forKey: "status")
            
            //call function to save data into firebase
            self.saveUserDataToFirebase()
        }
            
        }
    
    func createAssetReport(){
        self.hasLoaded = false
        
        let json: [String: Any] = [
            "accessToken": UserDefaults.standard.string(forKey: "access_token") as! String,
            "daysRequested": 60
        ]
        
        Functions.functions().httpsCallable("createAssetReport").call(json) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            let assetReportToken = result?.data as! String
            UserDefaults.standard.set(assetReportToken, forKey: "asset_report_token")
            
            self.hasLoaded = true
            
            ///save asset report to firebase!! in case I need to retrieve it later!
            if let loggedInUser = Auth.auth().currentUser {
                let db = Firestore.firestore()
                
                let ref = db.collection("users").document(loggedInUser.phoneNumber!)
                ref.setData(["asset_report" : assetReportToken], merge: true) { err in
                    if let err = err {
                        print("Error writing document users collection: \(err)")
                    } else {
                        print("Document successfully update!")
                    }
                }
            }

            
            //now I just need to call asset get pdf
            
            //save the report id in firebase and the pdf as well
        }
    }
    
    func getAssetReportPDF(){
        self.hasLoaded = false;
        let json: [String: Any] = [
            "assetReportToken": UserDefaults.standard.value(forKey: "asset_report_token") as! String
        ]
        
        Functions.functions().httpsCallable("getAssetReportPdf").call(json) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
        
            //convert the string base64 into Data
            let dataPDF = Data(base64Encoded: result?.data as! String, options: .ignoreUnknownCharacters)
            print(dataPDF)
            //let dataPDF = NSData(base64Encoded: result?.data, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) as Data?
            
            //write it in firebase bucket(PDF)
            let storage = Storage.storage()
            //let user = UserService.shared.user
            
            let uploadMetaData = StorageMetadata()
            uploadMetaData.contentType = "application/pdf"
            
            
            if let loggedInUser = Auth.auth().currentUser {
                //SAVE pdf TO STORAGE
                ///reference to storage root, bucket is userDocument id, then files are photo uploaded with a unique id

                // Create Date Formatter
                let df = DateFormatter()

                // Set Date Format
                let dateName = df.dateFormat = "YY/MM/dd"
                let dateNameForPDF = df.string(from: Date())
            
                
                let storageRef = storage.reference().child("Asset reports").child(loggedInUser.phoneNumber!).child(String(dateNameForPDF))
                let uploadTask = storageRef.putData(dataPDF!, metadata: uploadMetaData){
                    (_, err) in
                    if let err = err {
                        print("an error has occurred - \(err.localizedDescription)")
                    } else {
                        print("pdf uploaded successfully")
                        
                        ///SAVE pdf URL AS REFERENCE IN USER COLLECTION
                        ///

                        let db = Firestore.firestore()
                        
                        let ref = db.collection("users").document(loggedInUser.phoneNumber!)
                        
                        //download URL of the pic just posted
                        storageRef.downloadURL { url, error in
                            
                            ref.setData(["asset_report": url!.absoluteString ], merge: true) { err in
                                if let err = err {
                                    print("Error writing pdf url: \(err)")
                                } else {
                                    print("url successfully saved!")
                                }
                            }
                        }
                    }
                }
            }
            

            
            //save the report id in firebase and the pdf as well

        }
    }
    
    func saveUserDataToFirebase() {
        
        //create user with auth
        //probably this was done while doing phone verification
        
        
        if let loggedInUser = Auth.auth().currentUser {
            
            
            let db = Firestore.firestore()
            
            //save lead to "leads" collection
            let refLead = db.collection("leads").document(loggedInUser.phoneNumber!)
            refLead.setData(["name" : "NEED TO CALL identity plaid",
                             "phone" : loggedInUser.phoneNumber!,
                             "total_earnings" : self.totalEarned,
                             "total_spending" : self.totalSpent,
                             "address" : listingAddress,
                             "price" : "need to put price",
                             "type" : "rent",
                             "submitted_date" : Date(),
                             "plaid_exec_date" : Date(),
                             "status" : "Pending Application"
                            ], merge: true) { err in
                if let err = err {
                    print("Error writing document leads collection: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            
            //save to the db the user
            
            let ref = db.collection("users").document(loggedInUser.phoneNumber!)
            ref.setData(["name" : "NEED TO CALL identity plaid",
                         "phone" : loggedInUser.phoneNumber!,
                         "total_earnings" : self.totalEarned,
                         "total_spending" : self.totalSpent,
                         "leads_address" : FieldValue.arrayUnion([listingAddress]),
                         "leads" : "a subcollection or just a reference?",
                         "current_application" : listingAddress
                        ], merge: true) { err in
                if let err = err {
                    print("Error writing document users collection: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
                
                //save balance and transactions
            }
            
            
        }
        
        func load(){
            createAssetReport()
            getBalance()
            getTransactions()
            
        }
    }
    
    extension UserData {
        
        struct Transaction: Identifiable {
            var id = UUID()
            let categories: [String]?
            var category: Category?
            let name: String
            let payment_channel: String
            let amount: Double
            let date: String
            let pending: Bool
            
            
            //        func color() -> Color {
            //            return category!.color
            //        }
        }
        
        enum Category : Int, CaseIterable {
            case Food
            case Healthcare
            case Recreation
            case Auto
            case Bills
            case Travel
            case Shopping
            case PersonalCare
            case HomeImprovement
            case Community
            case Services
            case Miscellaneous
            case CC
            
            static let names: [Category: String] = [
                .Food : "Food & Restaurants",
                .Healthcare : "Healthcare",
                .Recreation : "Recreation",
                .Auto : "Auto & Transport",
                .Bills : "Bills",
                .Travel : "Travel",
                .Shopping : "Shopping",
                .PersonalCare : "Personal Care",
                .HomeImprovement : "Home Improvement",
                .Community :"Community",
                .Services : "Services",
                .Miscellaneous : "Miscellaneous",
                .CC : "Credit Card"
                
            ]
            
            static let keys: [Category: String] = [
                .Food : "Food",
                .Healthcare : "Healthcare",
                .Recreation : "Recreation",
                .Auto : "Auto",
                .Bills : "Bills",
                .Travel : "Travel",
                .Shopping : "Shops",
                .PersonalCare : "PersonalCare",
                .HomeImprovement : "HomeImprovement",
                .Community :"Community",
                .Services : "Services",
                .Miscellaneous : "Miscellaneous",
                .CC : "Credit Card"
            ]
            
            //        static let colors: [Category: Color] = [
            //            .Food : teal,
            //            .Healthcare : pink,
            //            .Recreation : orange,
            //            .Auto : green,
            //            .Bills : blue,
            //            .Travel : blue,
            //            .Shopping : yellow,
            //            .PersonalCare : lightPurple,
            //            .HomeImprovement : darkPurple,
            //            .Community : indigo,
            //            .Services : red,
            //            .Miscellaneous : teal,
            //            .CC : lightPurple
            //        ]
            
            static let iconNames: [Category: String] = [
                .Food : "cart.fill",
                .Healthcare : "cross.case.fill",
                .Recreation : "gamecontroller.fill",
                .Auto : "car.fill",
                .Bills : "house.fill",
                .Travel : "airplane",
                .Shopping : "bag.fill",
                .PersonalCare : "PersonalCare",
                .HomeImprovement : "house.fill",
                .Community :"person.3.fill",
                .Services : "wrench.fill",
                .Miscellaneous : "ellipsis.circle.fill",
                .CC : "creditcard.fill"
            ]
            
            var name: String {
                return Category.names[self]!
            }
            
            var key: String {
                return Category.keys[self]!
            }
            
            //        var color: Color {
            //            return Category.colors[self]!
            //        }
            
            var iconName: String {
                return Category.iconNames[self]!
            }
        }
        
    }
