//
//  ListingDetailView.swift
//  Reny
//
//  Created by Nat-Serrano on 11/16/21.
//

import SwiftUI
import SDWebImageSwiftUI
import iPhoneNumberField
import Firebase
import FirebaseFirestore
//import FirebaseStorage
import FirebaseAuth
import FirebaseFunctions
import MapKit
import GoogleMobileAds
import StoreKit


struct ListingDetailView: View {
    
    @EnvironmentObject var model: ContentModel
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var plaid : PlaidAPI
    @EnvironmentObject var purchaseManager: PurchaseManager
    //@StateObject var viewC : ViewController
    @Environment(\.presentationMode) var presentationMode
    
    //in app purchases
    //@StateObject var storeManager: StoreManager
    
    @State private var scrollViewID = UUID()
    @State var listing: Listings //pass the listing
    
    @State private var showSignInSheet = false
    
    
    @State var withdrawedApp = false
    
    //@State var plaidExecDate = nil
    
    @State private var isPresented = false
    
    @State var showLink = false //for plaid modal
    @State var plaidDone = false //for plaid modal to show sent Application
    @State var appRecently = false //for plaid modal to show sent Application
    
    @State var region = MKCoordinateRegion()
    
#if DEV
    let productIds = ["APTRT.Reny.financialCheck.dev", "APTRT.Reny.visit.dev"]
#else
    let productIds = ["APTRT.Reny.financialCheck", "APTRT.Reny.visit"]
#endif
    @State var products: [Product] = []
    
    @State private var showingSheet = false //for floor plan modal
    
    var body: some View {
        VStack {
            //just to test push github
            ScrollViewReader {ProxyReader in
                ScrollView(.vertical, showsIndicators: false, content: {
                    
                    //Listings
                    LazyVStack {
                        //MARK: - BUTTON TO SHOW SLIDER
                        Button {
                            self.isPresented.toggle()
                            
                            //                            if storeManager.transactionState == .purchased {
                            //
                            //                            }
                        } label: {
                            if listing.photos != nil {
                                ImageSliderView(images: listing.photos ?? [], homeVista: true)
                                    .frame(height: 300)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            } else {
                                Image("noImage")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .scaledToFill()
                                    .frame(width: 400, alignment: .center)
                                    .cornerRadius(10)
                                    .padding(10)
                            }
                        }
                        
                        //IMAGES
                        .fullScreenCover(isPresented: $isPresented, content: {
                            imagesFullScreenView.init(listingFullScreen: listing)
                        })
                        
                        ScrollView(.horizontal) {
                            HStack {
                                let priceInt = Int(listing.price)
                                Text("$\(String(priceInt))")
                                    .font(.title)
                                
                                HStack {
                                    HStack {
                                        Image(systemName: "bed.double.fill")
                                        Text(listing.bedroom?.prefix(1) ?? "")
                                    }
                                    
                                }
                                

                                    HStack {
                                        Image("toilet")
                                            .resizable()
                                            .frame(width: 40, height: 30, alignment: .center)
                                        Text(listing.bath?.prefix(1) ?? "0")
                                    }
                                
                                if listing.dishwasher {
                                        Image("dishwasher")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .center)
                                }
                                
                                if listing.washer_and_dryer {
                                        Image("washerAndDryer")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .center)
                                }
                                
                                if listing.elevator ?? false {
                                        Image("elevator")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .center)
                                }
                                
                                if listing.floor_plan != nil {
                                    
                                    Button {
                                        showingSheet.toggle()
                                    } label: {
                                        Image("floorplan")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .center)
                                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(.blue, lineWidth: 4))
                                    }
                                    .sheet(isPresented: $showingSheet) {
                                        floorPlanModal(floorPlanUrl: listing.floor_plan ?? "")
//                                            .presentationDetents([.medium])
//                                            .presentationDragIndicator(.visible)
                                    }
                                    
                                        
                                }
                                
                            }.padding(.horizontal)
                        }
                        
                        //MARK: - MapView with location for this address
                        NavigationLink(destination: mapLocation(region: region, listing: listing)) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text(listing.address ?? "")
                            }
                            .padding(.bottom, 10)
                            .frame(alignment: .leading)
                        }.frame(alignment: .leading)
                        
                        if listing.open_house !=  nil {
                            Text("Open House Dates").font(.title3)
                            //show all open house dates
                            ForEach(listing.open_house!, id: \.self) { date in
                                Text(date)
                            }
                        }
                        
                        //MARK: - Contact Agent
                        /*
                        ZStack {
                            if (UserDefaults.standard.string(forKey: "phone") == nil && model.loggedIn) ||
                                UserDefaults.standard.string(forKey: "current_application") != nil {
                                Rectangle().foregroundColor(.gray).frame(height: 40).cornerRadius(10)
                            } else {
                                Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                            }
                            
                            if listing.listed_by_url == nil || listing.listed_by_url == ""  {
                                Link(destination: URL(string: "https://media3.giphy.com/media/3o7btO8WLQFyw2q0Qo/giphy.gif?cid=ecf05e47cvpcfqcogxwxrccoeneli83j70x0d6bk7yhjmer6&rid=giphy.gif&ct=g")!) {
                                    Text("Contact an agent 15% fee")
                                        .foregroundColor(.white)
                                }
                            } else {
                                    Link(destination: URL(string: listing.listed_by_url!)!) {
                                        Text("Contact an agent 15% fee")
                                            .foregroundColor(.white)
                                }
                            }
//                            Button {
//
//                            } label: {
//                                Text("Contact an agent 15% fee")
//                            }
                        }.padding(.horizontal, 20)
                        */
                        
                        
                        //MARK: - SUBMIT PLAID APPLICATION
                        ZStack {
                            if (UserDefaults.standard.string(forKey: "phone") == nil && model.loggedIn) ||
                                UserDefaults.standard.string(forKey: "current_application") != nil {
                                Rectangle().foregroundColor(.gray).frame(height: 40).cornerRadius(10)
                            } else {
                                Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                            }
                            
                            Button {
                                //if user has PLaid LINKED then
                               
                                let accessTokenSetup = UserDefaults.standard.string(forKey: "access_token") ?? ""
                                //this step is important. is being used in UserData to save the lead in user doc and create a new lead
                                userData.listingAddress = listing.address ?? "No address"
                                
                                //to disable main screen until flow is completed
                                UserDefaults.standard.set(true, forKey: "application_in_progress")

                                
                                //if model.loggedIn == false {
                                if UserDefaults.standard.string(forKey: "phone") == nil {
                                    ///execute flow LOGIN/PHONE VERIFICATION -> PLAID LINK -> SAVE TO FIREBASE
                                    showSignInSheet = true
                                    
                                } else {
                                    ///if I'm logged in
                                    
                                    //authenticate to google again
                                    //not authenticated by google scenario
                                    if Auth.auth().currentUser == nil {
                                        //authenticate again
                                        showSignInSheet = true
                                    } else {
                                        //rest of the chorizo
                                        
                                        //if I have executed PLAID in the past
                                        if UserDefaults.standard.object(forKey: "plaid_exec_date") != nil {
                                            
                                            let plaidExecDate = UserDefaults.standard.object(forKey: "plaid_exec_date") as! Date
                                            let today = Date()
                                            let daysDiff = (plaidExecDate.distance(to: today))/86400 //to get number of days
                                            
                                            if daysDiff > 29 {
                                                //trigger IAP first, and if purchased go to plaid
                                                print("buying IAP")

                                                Task {
                                                    do {
                                                        let product = self.products.first
                                                        
                                                        try await purchaseManager.purchase(product!) //array has only one item
                                                    } catch {
                                                        print(error)
                                                    }
                                                }
                                            
                                                
                                            } else {
                                                //send to  SENT_VIEW
                                                plaid.vc.forceFlipForSentAppView()
                                                //userData.comingFrom = "notPlaid"
                                                self.plaidDone = true //send me to SentApplication view
                                                userData.scenario = "PlaidDoneLessThan30DaysAgo"
                                            }
                                            
                                        } else {
                                            //no plaid executed in the past
                                            
                                            //triger IAP
                                            //trigger plaid
                                            print("buying IAP")
                                           

                                            Task {
                                                do {
                                                    
                                                    let product = self.products.first
                                                    
                                                    try await purchaseManager.purchase(product!) //array has only one item
                                                } catch {
                                                    print(error)
                                                }
                                            }
                                            
                                            //query firebae for earnigs OR query plaid for transactions?
                                            
                                            
                                            //save lead and lead in subcollection of the user
                                        }
                                    }
                                    

                                }
                                
                            } label: {
                                //NEW APPROACH
                                //if this listing =  MY LAST APPLICATION (I can only have one!)
                                    Text("Apply with Reny").foregroundColor(.white)
                                
                            }
                            //disabled if user ALREADY SUBMITTED an application, why check phone is nil????
                            .disabled(UserDefaults.standard.string(forKey: "current_application") != nil && withdrawedApp == false)
                            .disabled(UserDefaults.standard.bool(forKey: "application_in_progress") == true)
        
                            
                            //MARK: - 1 LOGIN / PHONE AUTHENTICATION
                            .fullScreenCover(isPresented: $showSignInSheet, content: {
                                LoginView(isPresented: $showSignInSheet, plaidLink: $showLink, plaidDoneLess30DaysAgo: $plaidDone, products: self.products)
                            })
                            
                            //MARK: - 1.5 Check if listing is in attemptedToApplyProperties
                            
                            //MARK: - 2 IAP
                            
                            //MARK: - 3 Plaid Link
                            .sheet(isPresented: $purchaseManager.triggerPlaid, onDismiss: {
                                self.plaidDone = true
                                UserDefaults.standard.set(false, forKey: "application_in_progress")
                            }) {
                                LinkView()
                                //to pass environment var
                                    .environmentObject(ContentModel())
                            }
                            
                            //MARK: - 4 Sent application view & Results
                            .fullScreenCover(isPresented: $plaidDone, onDismiss: {
                                self.plaidDone = false
                            }) {
                                SentApplication(userData: userData, viewC: plaid.vc, listing: listing, plaidDoneLess30DaysAgo: $plaidDone, monthlyRent: listing.price)
                                    .environmentObject(UserData())
                                    .environmentObject(PlaidAPI())
                                    .environmentObject(ViewController())
                                    .onAppear() {
                                        
                                        //save to firebase the listing I applied to
                                        
                                        //save to userdefaults the listing I applied to
                                        UserDefaults.standard.set(listing.address ?? "", forKey: "current_application")
                                        UserDefaults.standard.set(Date(), forKey: "submitted_date")
                                        UserDefaults.standard.set(Date(), forKey: "plaid_exec_date")
                                        
                                        //for scenario that I already have an access token
                                        let accessTok = UserDefaults.standard.string(forKey: "access_token") ?? ""
                                        if accessTok != "" && userData.scenario != "PlaidDoneLessThan30DaysAgo" { //do not get transactions and balance if wee did PLaiud less than 30- days ago
                                            userData.load()
                                        }
                                        
                                    }
                                
                            }
                        }.padding(.horizontal, 20)
                        
                        Group {
                            ZStack {
                                if (UserDefaults.standard.string(forKey: "phone") == nil && model.loggedIn) ||
                                    UserDefaults.standard.string(forKey: "current_application") != nil {
                                    Rectangle().foregroundColor(.gray).frame(height: 40).cornerRadius(10)
                                } else {
                                    Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                                }
                                
                                Button {
                                    print("buying IAP")
                                    
                                    Task {
                                        do {
                                            //let visitProduct = purchaseManager.products.last
                                            let product = self.products.last
                                            //let product = purchaseManager.products.first
                                            try await purchaseManager.purchase(product!) //array has only one item
                                        } catch {
                                            print(error)
                                        }
                                    }
                                    
                                    
                                } label: {
                                    //NEW APPROACH
                                    //if this listing =  MY LAST APPLICATION (I can only have one!)
                                        Text("Hire a local to visit the listing for me").foregroundColor(.white)
                                    
                                }
                                
//                                .sheet(isPresented: $storeManager.triggerVisit, onDismiss: {
//
//                                    UserDefaults.standard.set(true, forKey: "visitRequested")
//                                }) {
////                                    EmailHelper.shared.sendEmail(subject: "Visit the apt on my behalf", body: "Location: \(listing.address), My phone number:", to: "nat.serrano@reny.app")
//                                }

                            }.padding(.horizontal, 20)
                                .onAppear() {
                                    if purchaseManager.triggerVisit ==  true {
                                        EmailHelper.shared.sendEmail(subject: "Visit the apt on my behalf", body: "Location: \(listing.address), My phone number:", to: "nat.serrano@reny.app")
                                    }
                                }
                        }
                        

                            
                        
                        //MARK: - get landlord data, call nyc open data
//                        NavigationLink {
//                            LandlordView()
//                                .onAppear() {
//                                    //call landlord function in view model
//                                    model.getLandlordData()
//                                }
//                        } label: {
//                            Image(systemName: "folder")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 30, height: 30, alignment: .center)
//                        }.padding(.horizontal, 10).padding(.top).padding(.bottom,0)
                        
                        //withdraw application button
                        if UserDefaults.standard.string(forKey: "current_application") != nil {
                            ZStack {
                                Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                                Button {
                                    //save data to firebase, update user
                                    if let loggedInUser = Auth.auth().currentUser {
                                        
                                        let db = Firestore.firestore()
                                        
                                        let ref = db.collection("users").document(loggedInUser.phoneNumber!)
                                        ref.setData(["current_application" : ""], merge: true) { err in
                                            if let err = err {
                                                print("Error writing document users collection: \(err)")
                                            } else {
                                                print("Document successfully update!")
                                            }
                                        }
                                        
                                    }
                                    
                                    //update user shared data
                                    UserDefaults.standard.set(nil, forKey: "current_application")
                                    
                                    //to refresh view
                                    withdrawedApp = true
                                } label: {
                                    Text("withdraw my application to \(UserDefaults.standard.string(forKey: "current_application") ?? "")")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        #if DEV
                        //remove user completely
                        if UserDefaults.standard.string(forKey: "phone") != nil {
                            Button(action: {
                                UserDefaults.standard.set(nil, forKey: "current_application")
                                UserDefaults.standard.set(nil, forKey: "name")
                                UserDefaults.standard.set(nil, forKey: "phone")
                                UserDefaults.standard.set(nil, forKey: "submitted_date")
                                UserDefaults.standard.set(nil, forKey: "plaid_exec_date")
                                
                            }) {
                                Text("remove user link completely")
                            }
                        }

                        
                        if UserDefaults.standard.string(forKey: "current_application") != nil {
                            Button(action: {
                                //let submDate = UserDefaults.standard.object(forKey: "submitted_date") as! Date
                                let twoMonthsAgo = Date.now.addingTimeInterval((86400*60) * -1) //86400 secs in a day
                                UserDefaults.standard.set(twoMonthsAgo, forKey: "plaid_exec_date")
                                
                            }) {
                                Text("make my plaid application 30+ days older")
                            }
                        }
                        #endif
                        
                        Group {
                            //Description of the listing, the text pues...
                            Text(listing.description ?? "")
                                .padding()
                                .font(.footnote)
                            
                            BannerAd(unitID: "ca-app-pub-8787171365157933/2845789069")
                        }

                        
                        //Description of the listing, the text pues...
//                        Text(String(listing.new_listing ?? 0) + " days in the market")
//                            .padding()
//                            .font(.footnote)

                    }
//                    .overlay(//banner google ads
//                        BannerAd(unitID: "ca-app-pub-8787171365157933/2845789069"), alignment: .bottom)
                    .id("SCROLL_TO_TOP")
                    .background(Color(.systemGroupedBackground))
                    
                })//scroll view
                //to recreate the veiw from scratch
                .id(self.scrollViewID)
            }
            
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Text(listing.address ?? "")
                Spacer()
                //Image(systemName: "heart")
                Button(action: shareButton) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30, alignment: .center)
                }
                
                Menu(content: {
//                    Button {
//                        //sign out
//                        try! Auth.auth().signOut()
//
//                        model.loggedIn = false
//                        //why delete access token??????
//                        UserDefaults.standard.set("", forKey: "access_token")
//                        UserDefaults.standard.set(nil, forKey: "current_application")
//                    } label: {Text("Sign out")}
                    
                }, label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large) //so  Ican easily click on it
                        .padding()
                })
                .padding(.trailing)
                .accentColor(.black)
            }
        }
        .onAppear() {

            //model.checkLogin() //COMMENTED UNTIL I FIGURE OUT how to fix the emptyusershared seervice
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: listing.latitude, longitude: listing.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            
            UserDefaults.standard.set(false, forKey: "application_in_progress")
            

        }
        .task {
            if self.products.count == 0 {
                do {
                    //try await purchaseManager.loadProducts()
                    self.products = try await Product.products(for: productIds.sorted())
                }
                catch {print(error)}
            }
        }
        
    }

    
    func shareButton() {
            let url = URL(string: "https://reny.app")
            let activityController = UIActivityViewController(activityItems: [url!], applicationActivities: nil)

            UIApplication.shared.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)
    }
}


struct LoginView: View {
    
    @EnvironmentObject var model: ContentModel
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.presentationMode) var presentationMode
    
    @State var login2ndScreen = false
    
    @State var email: String = ""
    @State var password: String = ""
    @State var errorMsg: String? //? means nil
    
    @Binding var isPresented: Bool
    @Binding var plaidLink: Bool
    @Binding var plaidDoneLess30DaysAgo: Bool
    
    //@StateObject var storeManager: StoreManager
    
    @State var isEditing: Bool = false
    
    @State var phNumber = ""
    @State private var phCode = ""
    
    @State var verifID : String = ""
    @State var applicationAlreadySubmitted = false
    @State var daysDiff = -5.0
    
    @State var products: [Product]
    
    var body: some View {
        
        if !login2ndScreen {
            //first screen
            VStack {
                Spacer()
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50, alignment: .center)
                
                Text("Create an account").font(.title)
                
                iPhoneNumberField("000 000 0000", text: $phNumber, isEditing: $isEditing)
                    .flagHidden(false)
                    .prefixHidden(false)
                    //.flagSelectable(true)
                    .autofillPrefix(true)
                    //.defaultRegion("+1")
                    .font(UIFont(size: 25, weight: .light, design: .monospaced))
                    .maximumDigits(10)
                    .foregroundColor(Color.blue)
                    .clearButtonMode(.whileEditing)
                    .onClear { _ in isEditing.toggle() }
                    .accentColor(Color.blue)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: isEditing ? Color(UIColor.lightGray) : Color.blue, radius: 10)
                    .padding()
                
                Text("Reny will send you a text with a verification code. Message and data rates may apply.")
                    .font(.system(size: 10.0))
                    .fontWeight(.light)
                    .foregroundColor(Color(UIColor.lightGray) )
                    .padding()
                
                if errorMsg != nil {
                    Text(errorMsg!)
                }
                
                Button {
                    
                    if phNumber.first != "+" {
                        phNumber = "+1 " + phNumber
                    }
                    
                    PhoneAuthProvider.provider()
                        .verifyPhoneNumber(phNumber, uiDelegate: nil) { verificationID, error in
                            if let error = error {
                                //self.showMessagePrompt(error.localizedDescription)
                                print(error.localizedDescription)
                                return
                            }
                            // Sign in using the verificationID and the code sent to the user
                            // ...
                            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                            verifID = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
                            login2ndScreen = true //switch to 2nd view or 2nd screen of login to input code
                        }
                    
                    
                } label: {
                    ZStack {
                        Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                        Text("Send code").foregroundColor(.white).font(.title)
                    }
                }.padding(.horizontal,40)
                
                
                Spacer()
            }
            .overlay(
                Button(action: {
                    //dismiss modal
                    UserDefaults.standard.set(false, forKey: "application_in_progress")
                    presentationMode.wrappedValue.dismiss()
                    
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size:50, weight: .semibold))
                        .foregroundColor(.black)
                        //.padding(0)
                        .background(Color.white)
                        .clipShape(Circle())
                })
                .padding(.trailing)
                .padding(.bottom, getSafeArea().bottom == 0 ? 12 : 0) //this is an if statement
                //.opacity(-scrollViewOffset > 450 ? 1 : 0).0'...0.0.0''
                
                
                //fixing at bottom left the floating rejection !!
                , alignment: .topLeading
            )
        } else {
            //2nd view to input phone number code
            VStack {
                Spacer()
                Image(systemName: "lock.shield.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50, alignment: .center)
                
                Text("Enter your verification code").font(.title)
                
                TextField("Code", text: $phCode)
                    .keyboardType(.numberPad)
                    .font(.system(size: 56.0))
                    .foregroundColor(Color.blue)
                    .accentColor(Color.blue)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.blue, radius: 10)
                
                //sent
                Button {
                    
                    let credential = PhoneAuthProvider.provider().credential(
                        withVerificationID: verifID,
                        verificationCode: phCode
                    )
                    
                    ///USER DEFAULTS APPROACH
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            ///bring the date
                            if UserDefaults.standard.object(forKey: "submitted_date") != nil {
                                //user submitted an app before
                                let submittedDate = UserDefaults.standard.object(forKey: "submitted_date") as! Date
                                let today = Date()
                                daysDiff = (submittedDate.distance(to: today))/86400 //to get number of days
                                
                                //I already submitted an app in the last 30 days
                                if daysDiff < 30 && daysDiff > 0 {
                                    //already submitted application
                                    
                                    login2ndScreen = false
                                    presentationMode.wrappedValue.dismiss()
                                    //applicationAlreadySubmitted = true
                                    
                                    //do binding of plaidDone var
                                    plaidDoneLess30DaysAgo = true
                                } else { //do a pLAID LINK AGAIN
                                    print("PLaid link again baby!, 30+ days since last link!")
                                    //just populate usershared service
                                    let phNum = phNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                                    UserDefaults.standard.set(phNum, forKey: "phone")
                                    UserDefaults.standard.set(Date(), forKey: "submitted_date")
                                    
                                    //self.showMessagePrompt(error.localizedDescription)
                                    login2ndScreen = false //switch to 2nd view or 2nd screen of login to input code
                                    
                                    //send to IAP instead!!
                                    print("buying IAP")

                                    Task {
                                        do {
                                            let product = self.products.first
                                            
                                            try await purchaseManager.purchase(product!) //array has only one item
                                        } catch {
                                            print(error)
                                        }
                                    }
                                    
                                    plaidDoneLess30DaysAgo = false
                                    
                                    //plaidLink = true
                                    presentationMode.wrappedValue.dismiss()
                                    return
                                }
                            } else {
                                //BRAD NEW APPLICATION BABY!
                                print("BRAD NEW APPLICATION BABY!!")
                                //just populate usershared service
                                let phNum = phNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                                UserDefaults.standard.set(phNum, forKey: "phone")
                                UserDefaults.standard.set(Date(), forKey: "submitted_date")
                                
                                //self.showMessagePrompt(error.localizedDescription)
                                login2ndScreen = false //switch to 2nd view or 2nd screen of login to input code
                                
                                //send to IAP instead!!
                                print("buying IAP")
                                Task {
                                    do {
                                        let product = self.products.first
                                        
                                        try await purchaseManager.purchase(product!) //array has only one item
                                    } catch {
                                        print(error)
                                    }
                                }
                                
                                
                                plaidDoneLess30DaysAgo = false
                                
                                //plaidLink = true
                                presentationMode.wrappedValue.dismiss()
                                return
                            }
                            
                        }
                    }
                    
                    
                    ///FIREBASE APPROACH
                    /*Auth.auth().signIn(with: credential) { authResult, error in
                     if let error = error {
                     print(error.localizedDescription)
                     } else {
                     
                     ///SUCCESFUL CODE
                     ///WAIT...WHAT USER DATA WILL I GET IF IT IS A NEW A USER?????!!!
                     ///
                     if let loggedInUser = Auth.auth().currentUser {
                     let db = Firestore.firestore()
                     let ref = db.collection("users").document(loggedInUser.phoneNumber!)
                     
                     ref.getDocument { (document, error) in
                     
                     guard error == nil, document != nil else {
                     return
                     }
                     
                     if document!.exists {
                     //print("Document data: \(document.data())")
                     //Task { await model.getUserData() }
                     
                     let data = document!.data()
                     
                     UserServic.shared.user.name = data?["name"] as? String ?? ""
                     UserServic.shared.user.phone = data?["phone"] as? String ?? ""
                     UserServic.shared.user.total_earnings = data?["total_earnings"] as? Int ?? 0
                     UserServic.shared.user.total_spending = data?["total_spending"] as? Int ?? 0
                     UserServic.shared.user.leads_address = data?["leads_address"] as? [String] ?? []
                     UserServic.shared.user.current_application = data?["current_application"] as? String ?? ""
                     UserServic.shared.user.submitted_date = data?["submitted_date"] as? Date ?? Date()
                     
                     ///CHECK IF USER SUBMITTTED AN APPLICATION LESS THAN 30 DAYS AGO
                     ///
                     let today = Date()
                     let submittedDate = UserServic.shared.user.submitted_date
                     daysDiff = (submittedDate.distance(to: today))/86400 //to get number of days
                     
                     //I already submitted an app in the last 30 days
                     if daysDiff < 30 && daysDiff > 0 {
                     //if UserServic.shared.user.leads_address.contains(userData.listingAddress) {
                     //already submitted application
                     
                     login2ndScreen = false
                     presentationMode.wrappedValue.dismiss()
                     //applicationAlreadySubmitted = true
                     
                     //do binding of plaidDone var
                     plaidDoneLess30DaysAgo = true
                     } else {
                     //self.showMessagePrompt(error.localizedDescription)
                     login2ndScreen = false //switch to 2nd view or 2nd screen of login to input code
                     
                     //send to IAP instead!!
                     print("buying IAP")
                     let product = storeManager.myProducts.first
                     storeManager.purchaseProduct(product: product!) //array has only one item
                     
                     plaidDoneLess30DaysAgo = false
                     
                     //plaidLink = true
                     presentationMode.wrappedValue.dismiss()
                     return
                     }
                     
                     } else {
                     ///BRAD NEW APPLICATION, PAY BABY!
                     ///
                     print("Document does not exist")
                     //just populate usershared service
                     UserServic.shared.user.phone = loggedInUser.phoneNumber!
                     UserServic.shared.user.current_application = ""
                     //UserServic.shared.user.submitted_date = Date()
                     
                     //self.showMessagePrompt(error.localizedDescription)
                     login2ndScreen = false //switch to 2nd view or 2nd screen of login to input code
                     
                     //send to IAP instead!!
                     print("buying IAP")
                     let product = storeManager.myProducts.first
                     storeManager.purchaseProduct(product: product!) //array has only one item
                     
                     plaidDoneLess30DaysAgo = false
                     
                     //plaidLink = true
                     presentationMode.wrappedValue.dismiss()
                     return
                     }
                     
                     
                     }
                     }
                     }
                     }*/
                    
                } label: {
                    ZStack {
                        Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                        Text("Confirm").foregroundColor(.white).font(.title)
                    }
                }
                .alert("already submitted application", isPresented: $applicationAlreadySubmitted) {
                    Button("OK", role: .cancel) {}
                }
                .padding(.horizontal,40)
                
                Spacer()
            }
            .overlay(
                Button(action: {
                    //dismiss modal
                    UserDefaults.standard.set(false, forKey: "application_in_progress")
                    presentationMode.wrappedValue.dismiss()
                    
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size:50, weight: .semibold))
                        .foregroundColor(.black)
                        //.padding(0)
                        .background(Color.white)
                        .clipShape(Circle())
                })
                .padding(.trailing)
                .padding(.bottom, getSafeArea().bottom == 0 ? 12 : 0) //this is an if statement
                //.opacity(-scrollViewOffset > 450 ? 1 : 0).0'...0.0.0''
                
                
                //fixing at bottom left the floating rejection !!
                , alignment: .topLeading
            )
        }
        
    }
}

struct mapLocation: View {
    @State var region = MKCoordinateRegion()
    
    var listing: Listings
    
    var body: some View {

        
        Map(coordinateRegion: $region,annotationItems: [listing]) { listing1 in
            // ... create a custom MapAnnotation
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: listing1.latitude, longitude: listing1.longitude)) {
                
                PlaceAnnotationView(title: listing.priceShort ?? "")
                
            }
        }
    }
}

struct floorPlanModal: View {
    @Environment(\.dismiss) var dismiss
    
    var floorPlanUrl: String

    var body: some View {
        
        VStack{
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "line.3.horizontal")
            }
            .font(.title)
            .padding()
            .background(.black)
            
            //let url = Bundle.main.url(forResource: floorPlanUrl, withExtension: String?)
            
            WebImage(url: URL(string: floorPlanUrl))
                .resizable()
                .aspectRatio(contentMode: .fit)
                //.scaledToFill()
                //.frame(width: 250, alignment: .center)
                .cornerRadius(10)
                .padding(10)

        }

    }
}

struct imagesFullScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var listingFullScreen: Listings
    
    var body: some View {
        VStack {
            ImageSliderView(images: listingFullScreen.photos ?? [], homeVista: false)
                .frame(height: 600)
            
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .frame(width: .infinity, height: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            presentationMode.wrappedValue.dismiss()
        }
        
    }
}

extension UINavigationController {
    
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
    
}


extension View{
    func getSafeArea()->UIEdgeInsets {
        return UIApplication.shared.windows.first?.safeAreaInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

struct BannerAd: UIViewRepresentable{
    
    var unitID: String
    
    func makeCoordinator() -> Coordinator {
        // For Implementing Delegates...
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> GADBannerView{
        
        let adView = GADBannerView(adSize: GADAdSizeBanner)
        
        adView.adUnitID = unitID
        adView.rootViewController = UIApplication.shared.getRootViewController()
        adView.delegate = context.coordinator
        adView.load(GADRequest())
        
        return adView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        
    }
    
    class Coordinator: NSObject,GADBannerViewDelegate{
        
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
          print("bannerViewDidReceiveAd")
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
          print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }

        func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
          print("bannerViewDidRecordImpression")
        }

        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
          print("bannerViewWillPresentScreen")
        }

        func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
          print("bannerViewWillDIsmissScreen")
        }

        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
          print("bannerViewDidDismissScreen")
        }
    }
}

// Extending Application to get RootView...
extension UIApplication{
    func getRootViewController()->UIViewController{
        
        guard let screen = self.connectedScenes.first as? UIWindowScene else{
            return .init()
        }
        
        guard let root = screen.windows.last?.rootViewController else{
            return .init()
        }
        
        return root
    }
}
