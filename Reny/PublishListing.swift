//
//  PublishListing.swift
//  Reny
//
//  Created by Nat-Serrano on 8/16/22.
//

import SwiftUI
import iPhoneNumberField
//import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CoreLocation
//import PhotosUI
import MapKit

struct PublishListing: View {
    @State var page : Int
    @StateObject private var mapSearch = MapSearch() //jnpdx
    @EnvironmentObject var model: ContentModel
    
    @State var pickerResult: [UIImage] = [] //for the images selected
    
    //@StateObject var imageController = ImageController()
    
    @State private var date = Date() //date selected or END OF LEASE
    @State private var selectedDate = false
    @State private var showingAlert = false
    
    @State private var imagesString : [String] = []
    
    @State private var price : String = ""
    @State private var addressListing : String = ""
    @State private var interior : String = ""
    @State private var bedrooms = 0
    @State private var bathrooms = 0
    @State private var doorman  = false
    @State private var elevator  = false
    @State private var dishwasher  = false
    @State private var laundry  = false
    @State private var washer  = false
    @State private var patio  = false
    @State private var lat  = 0.0
    @State private var lon  = 0.0
    
    @State private var login2ndScreen = false
    @State private var verifID : String = ""
    @State private var phCode = ""
    
    @State private var showImagePicker: Bool = false
    
    @State private var isEditing: Bool = false
    
//    @State private var selectedItem: PhotosPickerItem? = nil
//    @State private var selectedImageData: Data? = nil
    
    @State private var phNumber = ""
    @State private var name = ""

    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        if page == 0 {
            
            
            VStack {
                Text("When does your lease expire?").font(.title)
                        DatePicker("Enter the lease end date", selection: $date, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .frame(maxHeight: 400)
                            .onChange(of: date, perform: { value in
                                 // Do what you want with "date", like array.timeStamp = date
                                selectedDate = true
                            });
            }
            
            Button {
                if selectedDate {
                    page = 1
                } else {
                    showingAlert = true
                }
                
            } label: {Text("Next").font(.title)}
                .alert("Select your lease end Date", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                        }
        }
        
        if page == 1 {
            
            //implement the search in filter view, exactly the same
            VStack(alignment: .leading){
                //Form {
                Section {
                    Text("Where do you live?").font(.title)
                    TextField("Address", text: $mapSearch.searchTerm)
                        .textFieldStyle(.roundedBorder)
                        .cornerRadius(10)
                        .font(.headline)
                }.padding()
                
                TextField("Apartment", text: $interior)
                    .textFieldStyle(.roundedBorder)
                    .cornerRadius(10)
                    .font(.headline)
                
                //if self.showSection == true  {
                //if mapSearch.locationResults.count > 0 && mapSearch.isVisible == true {
                //show the section
                Section {
                    ForEach(mapSearch.locationResults, id: \.self) { location in
                        
                        if mapSearch.searchTerm != location.title {
                            Button {

                                mapSearch.locationResults = []

                                mapSearch.searchTerm = location.title
                                
                                addressListing = location.title //+ ", " + location.subtitle
                                
                                //use the MKLocalSearchCompletion to form an MKLocalSearchRequest
                                //let searchRequest = MKLocalSearch(request: .init(completion: location))
    
                                let searchRequest = MKLocalSearch.Request()
                                searchRequest.naturalLanguageQuery = addressListing
                                searchRequest.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.75773, longitude: -73.985708), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                                
                                let search = MKLocalSearch(request: searchRequest)
                                
                                search.start { response, error in
                                    guard let response = response else {
                                        print("Error: \(error?.localizedDescription ?? "Unknown error").")
                                        return
                                    }
                                    
                                    let placemark = response.mapItems[0].placemark
                                    self.lat = placemark.coordinate.latitude
                                    self.lon = placemark.coordinate.longitude
                                    
                                }
                                //perform the MKLocalSearch
                                
//                                search.start { (response, error) in
//
//                                    let placemark = response?.mapItems[0].placemark
//
//                                    self.onSearchMapChanged?(placemark!.coordinate)
//                                }
//
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(location.title)
                                    Text(location.subtitle)
                                        .font(.system(.caption))
                                }
                            }
                        }
                        
                    }
                }
                
            }.padding()
            
            
            Button {
                if addressListing != "" && interior != "" {
                    page = 2
                } else {
                    showingAlert = true
                }
                
                
            } label: {Text("Next")}
                .alert("Fill both fields", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                        }
        }
        
        if page == 2 {
            VStack {
                Text("How much do you pay per month?").font(.title)
                
                TextField("", text: $price)
                    .keyboardType(.numberPad)

                    .textFieldStyle(.roundedBorder)
                    .cornerRadius(10)
                    .font(.headline)
                
     //           TextField("", value: $price, formatter: NumberFormatter())
//                            .frame(width: 50)
//                        Stepper(value: $price, in: 1...8) {
//                            EmptyView()
//                        }
            }
            
            
            Button {
                if price != "" {
                    page = 3
                } else {
                    showingAlert = true
                }
                
                
            } label: {Text("Next").font(.title)}
                .alert("We need to know how much you pay per month", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                        }
        }
        
        if page == 3 {
            VStack {
                
                HStack {
                    Stepper("how many bedrooms?", value: $bedrooms, in: 0...5)
                    Text(" \(bedrooms)")
                }.padding()
            
                HStack {
                    Stepper("how many bathrooms?", value: $bathrooms, in: 0...5)
                    Text(" \(bathrooms)")
                }.padding()
                
                Toggle("do you have a dishwasher?", isOn: $dishwasher).padding()
                
                Toggle("do you have washer and dryer?", isOn: $washer).padding()
                
                Toggle("do you have laundry in the building?", isOn: $laundry).padding()
                
                Toggle("do you have a elevator?", isOn: $elevator).padding()
            
                Toggle("do you have a patio?", isOn: $patio).padding()
                
                Toggle("do you have a doorman?", isOn: $doorman).padding()
                
            }
            
            Button {page = 4} label: {Text("Next").font(.title)}
        }
        
        if page == 4 {
                //images
            VStack {
                
                Spacer()
                
                //add an image hstack
                if pickerResult.count > 0 {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(pickerResult, id: \.self) { img in
                                Image(uiImage: img)
                                    .resizable()
                                    .frame(width: 300, height: 300)
                            }
                        }
                    }
                }
                
                Button {
                    //pickerResult = []
                    showImagePicker.toggle()
                } label: {
                    Text("Upload some pictures of the apartment")
                }.padding()
                
                
                
                Button {page = 5} label: {Text("Next").font(.title)}.padding()
                
                Spacer()
        
            }
            //MARK: - SHOW THE picture yourself view
            .sheet(isPresented: $showImagePicker, content: {
                //call the helper image picker to select photos (PHPicker)
                ImagePicker(pickerResult: $pickerResult, showImagePicker: $showImagePicker)
            })
                

        }
        
        if page == 5 {
            if !login2ndScreen {
                VStack{
                    Section {
                        Text("What's your name?")
                        TextField("", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .cornerRadius(10)
                            .font(.headline)
                    }.padding()

                    
                    Text("What's your phone number?")
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
                    
                    Button {
                        
                        if name != "" {
                            //let editedPhone = phNumber.trimmingCharacters(in: .whitespacesAndNewlines)
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
                                    UserDefaults.standard.set(verificationID, forKey: "authVerificationIDposting")
                                    verifID = UserDefaults.standard.string(forKey: "authVerificationIDposting") ?? ""
                                    login2ndScreen = true //switch to 2nd view or 2nd screen of login to input code
                                }
                        } else {
                            showingAlert = true
                        }

                        
                    } label: {
                        ZStack {
                            Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                            Text("Send code").foregroundColor(.white).font(.title)
                        }
                    }
                    .padding(.horizontal,40)
                    .alert("Fill your contact information", isPresented: $showingAlert) {
                                Button("OK", role: .cancel) { }
                            }
                }//end of vstakc
            } else {
                //2nd screen - confirmation code
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
                                    page = 6
                                    login2ndScreen = false //switch to 2nd view or 2nd screen of login to input code

                                }
                                
                            }
                        
                    } label: {
                        ZStack {
                            Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                            Text("Next").foregroundColor(.white).font(.title)
                        }
                    }
                    .padding(.horizontal,40)
                    
                    Spacer()
                }
                
            }

        }
        
        if page == 6 {
            let payment = String(format: "%.0f", ((Double(price) ?? 0) * 12) * 0.03)
            Text("SUCCESS! Your listing is online. You'll make this much $\(payment) if your apartment gets rented via RENY").bold().font(.headline).padding()
            
            Button {
                
                
                //SAVE IMAGES TO FIREBASE STORAGE BUCKET!!
                let storage = Storage.storage()
                let db = Firestore.firestore()
                
                let uploadMetaData = StorageMetadata()
                uploadMetaData.contentType = "image/jpeg"
                
                if let loggedInUser = Auth.auth().currentUser {
                    
                    //SAVE LISTING TO FIREBASE
                    
                    let ref = db.collection("postedListings").document(addressListing + " " + interior)
                    ref.setData(["address" : addressListing,
                                 "price" : price,
                                 "bedrooms" : bedrooms,
                                 "bathrooms" : bathrooms,
                                 "date_available" : date,
                                 "doorman" : doorman,
                                 "elevator" : elevator,
                                 "dishwasher" : dishwasher,
                                 "laundry" : laundry,
                                 "washer" : washer,
                                 "patio" : patio,
                                 "images" : "", //pending to put an array with storage buckets links
                                 "posted_by" : name,
                                 "posted_by_number" : phNumber,
                                 "lat" : self.lat,
                                 "lon" : self.lon,
                                 "active" : true
                                ], merge: true) { err in
                        if let err = err {
                            print("Error writing document users collection: \(err)")
                        } else {
                            print("Listing successfully created!")
                        }
                    }
                    
                    //SAVE IMAGE TO STORAGE
                    ///reference to storage root, bucket is userDocument id, then files are photo uploaded with a unique id
                    
                    //for loop for all pictures
                    for (index, img) in pickerResult.enumerated() {
                        
                        let storageRef = storage.reference().child("ListingsPics").child(addressListing + " " + interior + "/\(index).jpeg")
                        
                        let uploadTask = storageRef.putData(img.jpegData(compressionQuality: 0.1)!, metadata: uploadMetaData){
                            (_, err) in
                            if let err = err {
                                print("an error has occurred - \(err.localizedDescription)")
                            } else {
                                print("pic uploaded successfully")
                                
                                ///SAVE pdf URL AS REFERENCE IN USER COLLECTION
                                
                                let ref = db.collection("postedListings").document(addressListing + " " + interior)
                                
                                //download URL of the pic just posted
                                storageRef.downloadURL { url, error in
                                    
                                    ref.updateData([
                                        "images": FieldValue.arrayUnion([url!.absoluteString]) //append an array
                                    ]){ err in
                                        if let err = err {
                                            print("Error writing pdf url: \(err)")
                                        } else {
                                            imagesString.append(url!.absoluteString)
                                            print("url successfully saved!")
                                        }
                                    }
                                }
                            }
                        }
                    }//end of for loop
                }

                //create a dummmy listing
                let newListing = Listings()
                
                // Create Date Formatter
                let df = DateFormatter()
                
                // Set Date Format
                //let dateName = df.dateFormat = "YY/MM/dd"
                let dateFormatted = df.string(from: self.date)
                
                newListing.address = addressListing
                newListing.neighborhood = ""
                newListing.zipcode = ""
                newListing.latitude = self.lat
                newListing.longitude = self.lon
                newListing.bedroom = String(bedrooms)
                newListing.bath = String(bathrooms)
                newListing.photos = imagesString //need to add strings
                newListing.video = ""
                newListing.description = ""
                //newListing.new_listing = addressListing
                newListing.date_available = dateFormatted
                //newListing.open_house = addressListing
                newListing.price = Double(self.price) ?? 0
                newListing.dishwasher = self.dishwasher
                newListing.washer_and_dryer = self.washer
                
                //newListing.pets_allowed =
                newListing.live_in_super = self.doorman
                newListing.elevator = self.elevator
                //newListing.url = addressListing
                //newListing.floor_plan = addressListing
                newListing.coordinate = Coordinate(latitude: self.lat, longitude: self.lon)
                
                
//                let geocoder = CLGeocoder()
//                let address = addressListing
//                geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
//                    if((error) != nil){
//                        print("Error with CLGEOCODER ", error ?? "")
//                    }
//                    if let placemark = placemarks?.first {
//                        let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
//                        newListing.coordinate = Coordinate(latitude: coordinates.latitude, longitude: coordinates.longitude)
//                        print("Lat: \(coordinates.latitude) -- Long: \(coordinates.longitude)")
//                    }
//                })
            
                
                let shortPrice = (Double(newListing.price ?? 0))/1000
                if String(shortPrice).last! == "0" {
                    newListing.priceShort = String(format: "%.0f", shortPrice) + "K"
                } else {
                    newListing.priceShort = String(format: "%.1f", shortPrice) + "K"
                }
                

                ///append that dummy listing to model.listings
                model.listingsZ.append(newListing)
                
                presentationMode.wrappedValue.dismiss()
                
//                ListingDetailView(model: <#T##ContentModel#>, userData: <#T##UserData#>, plaid: <#T##PlaidAPI#>, presentationMode: <#T##arg#>, storeManager: <#T##StoreManager#>, listing: <#T##Listings#>)
            } label: {
                Text("Next").font(.title)
                
            }.padding()
        }
    }
}

//struct PublishListing_Previews: PreviewProvider {
//    static var previews: some View {
//        PublishListing()
//    }
//}
