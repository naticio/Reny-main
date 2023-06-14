//
//  ContentModel.swift
//  Reny
//
//  Created by Nat-Serrano on 11/13/21.
//

import Foundation
import CoreLocation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase
import MapKit
//import IkigaJSON
//import ZippyJSON
import ExtrasJSON
import StoreKit

@MainActor class ContentModel: ObservableObject{ //o I need to put the final?
    //@Published public var results : Results? //type results
    //@Published public var listingsF : [Listing]?
    
    //@Published public var listPages : [listingsPage]?
    
    @StateObject var storeManager = StoreManager ()
    
    @Published public var listingsZ: [Listings] = []
    @Published public var listingsFZ: [Listings]?
    @Published public var buildings: [Building]?
    //@Published public var resultApify: LastRun?
    
    @Published var selectedView = "Search"
    
    //MARK: - change ENVIRONMENT when deploying to prod
    ///IMPORTANT
    //IMPORTANT TO CHANGE THIS WHEN DEPLOYING TO PROD!!
    @Published public var environment = "dev"
    
    //filter view vars
    @Published public var filters: Bool?
    @Published var selectedBedrooms = -1
    @Published var selectedPriceMin = ""
    @Published var selectedPriceMax = ""
    @Published var dishwasher = false
    @Published var washerAndDryer = false
    @Published var elevator = false
    
    @Published public var selectedLocation: MKLocalSearchCompletion = MKLocalSearchCompletion()
    //@Published var region: MKCoordinateRegion = MKCoordinateRegion()
    
    //@Published var jason : [String: Any]
    
    @Environment(\.presentationMode) var presentationMode
    
    @Published var loggedIn = false
    
    @Published var resultsFetched = false
    
    //MARK: - vars for map content model
    @Published var isLoading = true
    @Published private var coordinate : CLLocationCoordinate2D?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    
#if DEV
    let productIDs = ["APTRT.Reny.financialCheck.dev"]
#else
    let productIDs = ["APTRT.Reny.financialCheck"]
#endif
    
    var coordinateForMap : CLLocationCoordinate2D {
        coordinate ?? CLLocationCoordinate2D()
    }
    
    /*func getLocalData() {
     // Parse local json file
     // Get a url path to the json file
     let pathString = Bundle.main.path(forResource: "streeteasy", ofType: "json")
     
     // Check if pathString is not nil, otherwise...
     //guard pathString != nil else {return [ListingsZillow]()}
     
     // Create a url object
     let url = URL(fileURLWithPath: pathString!)
     
     do {
     
     // Create a data object
     let data = try Data(contentsOf: url)
     
     // Decode the data with a JSON decoder
     let decoder = JSONDecoder()
     
     do {
     self.listingsZ = try decoder.decode([Listings].self, from: data)
     
     print(self.listingsZ!.count)
     self.getShortPriceZillow()
     
     //add the status of application for each listing in parallel
     //self.getListingStatus()
     self.resultsFetched = true
     }
     catch {
     // error with parsing json
     print(error)
     }
     }
     catch {
     // error with getting data
     print(error)
     }
     }*/
    
    //to partially decode the json ASYNC
//    func reload() async {
//        let url = URL(string: "https://streeteasydaily.s3.us-west-2.amazonaws.com/streeteasy.json")!
//        let urlSession = URLSession.shared
//
//        do {
//            let (data, _) = try await urlSession.data(from: url)
//            self.listingsZ = try JSONDecoder().decode([Listings].self, from: data)
//        }
//        catch {
//            // Error handling in case the data couldn't be loaded
//            // For now, only display the error on the console
//            debugPrint("Error loading \(url): \(String(describing: error))")
//            print(error.localizedDescription)
//
//        }
//    }
    //https://www.icloud.com/iclouddrive/0edNFUodsvlOWPzZBRih6CV6w#json1500
    
    @MainActor func reload() async {
        let url = URL(string: "https://github.com/naticio/Reny/blob/main/Reny/json1500.json")!
        let urlSession = URLSession.shared

        do {
            let (data, _) = try await urlSession.data(from: url)
            self.listingsZ = try JSONDecoder().decode([Listings].self, from: data)
            print("got the JASON!")
            self.resultsFetched = true
            self.getSEListings()
        } catch {
            // Error handling in case the data couldn't be loaded
            // For now, only display the error on the console
            debugPrint("Error loading \(url): \(String(describing: error))")
            print("called before async finished!")
        }
    }

    func getSEListings1() -> Bool {
        
        var urlComponents = URLComponents(string: "https://streeteasydaily.s3.us-west-2.amazonaws.com/streeteasy1.json")

        urlComponents?.queryItems = []
        let url = urlComponents?.url
        
        if let url = url {
            
            // Create URL Request
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Get URLSession
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                // Fancy simplified way
                if error == nil {
                    do {
                        if data != nil {
//                            let json = try JSONSerialization.jsonObject(with: data!, options:[])
//                            print(json)
                            
                            let decodedResponse = try! XJSONDecoder().decode([Listings].self, from: data!)
                            
                            DispatchQueue.main.async {
                                self.listingsZ.append(contentsOf: decodedResponse)
                                self.resultsFetched = true
                                
                                print("finished decoding first SE 1")
                                //self.getShortPriceZillow()
                                for listing in self.listingsZ {
                                    
                                    listing.coordinate = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
                                    //coord.locationCoordinate()
                                    
                                    let shortPrice = (Double(listing.price ?? 0))/1000
                                    if String(shortPrice).last! == "0" {
                                        listing.priceShort = String(format: "%.0f", shortPrice) + "K"
                                    } else {
                                        listing.priceShort = String(format: "%.1f", shortPrice) + "K"
                                    }
                                    
                                    //condition bedrooms, para cuando venga nulo el culo
                                    var listingRooms = 0
                                    if listing.bedroom == nil {
                                        listing.bedroom = ""
                                    }
                                }
                                
                                self.getSEListings2() //get the rest of the json
                            }
                        
                        }
                    }
                    catch {print(error)}
                }
            }
            // Start the Data Task
            dataTask.resume()
            return true
        } else {
            return false
        }
    }
    
    func getListingsFromFirebase() {
        let db = Firestore.firestore()
        //get all  listings posted by users that are stll active
        let ref = db.collection("postedListings")
        
        db.collection("postedListings").whereField("active", isEqualTo: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        
                        let data = document.data()
                        
                        let newListing = Listings()
                        
                        newListing.address = data["address"] as? String ?? ""
                        //newListing.neighborhood = data?["address"] as? String ?? ""
                        //newListing.zipcode = ""
                        newListing.latitude = data["lat"] as? Double ?? 0.0
                        newListing.longitude = data["lon"] as? Double ?? 0.0
                        newListing.bedroom = data["bedrooms"] as? String ?? ""
                        newListing.bath = data["bathrooms"] as? String ?? ""
                        newListing.photos = data["images"] as? [String] ?? []
                        //newListing.video = ""
                        //newListing.description = ""
                        //newListing.new_listing = addressListing
                        newListing.date_available = data["date_available"] as? String ?? ""
                        //newListing.open_house = addressListing
                        newListing.price = Double(data["price"] as? String ?? "") ?? 0.0
                        newListing.dishwasher = data["dishwasher"] as? Bool ?? false
                        newListing.washer_and_dryer = data["washer"] as? Bool ?? false
                        
                        //newListing.pets_allowed =
                        newListing.live_in_super = data["doorman"] as? Bool ?? false
                        newListing.elevator = data["elevator"] as? Bool ?? false
                        //newListing.url = addressListing
                        //newListing.floor_plan = addressListing
                        newListing.coordinate = Coordinate(latitude: newListing.latitude, longitude: newListing.longitude)
                        
                        let shortPrice = (Double(newListing.price ?? 0))/1000
                        if String(shortPrice).last! == "0" {
                            newListing.priceShort = String(format: "%.0f", shortPrice) + "K"
                        } else {
                            newListing.priceShort = String(format: "%.1f", shortPrice) + "K"
                        }
                        
                        self.listingsZ.append(newListing)
                        print("Firebase listing added succesfully")
                            
                        //print("\(document.documentID) => \(document.data())")
                    }
                }
        }
    
    }
    
    func getSEListings2() -> Bool {
        
        var urlComponents = URLComponents(string: "https://streeteasydaily.s3.us-west-2.amazonaws.com/streeteasy2.json")

        urlComponents?.queryItems = []
        let url = urlComponents?.url
        
        if let url = url {
            
            // Create URL Request
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Get URLSession
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                // Fancy simplified way
                if error == nil {
                    do {
                        if data != nil {
//                            let json = try JSONSerialization.jsonObject(with: data!, options:[])
//                            print(json)
                            
                            let decodedResponse = try! XJSONDecoder().decode([Listings].self, from: data!)
                            
                            DispatchQueue.main.async {
                                self.listingsZ.append(contentsOf: decodedResponse)

                                print("finished decoding first SE 2")
                                //self.getShortPriceZillow()
                                let indexStart = (self.listingsZ.count - decodedResponse.count)-1
                                for (index, listing) in self.listingsZ.enumerated() where index > indexStart {
                                //for listing in self.listingsZ {
                                    
                                    listing.coordinate = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
                                    //coord.locationCoordinate()
                                    
                                    let shortPrice = (Double(listing.price ?? 0))/1000
                                    if String(shortPrice).last! == "0" {
                                        listing.priceShort = String(format: "%.0f", shortPrice) + "K"
                                    } else {
                                        listing.priceShort = String(format: "%.1f", shortPrice) + "K"
                                    }
                                    
                                    //condition bedrooms, para cuando venga nulo el culo
                                    var listingRooms = 0
                                    if listing.bedroom == nil {
                                        listing.bedroom = ""
                                    }
                                }
                                self.getSEListings3() //get the rest of the json
                            }
                        }
                    }
                    catch {print(error)}
                }
            }
            // Start the Data Task
            dataTask.resume()
            return true
        } else {
            return false
        }
    }
    func getSEListings3() -> Bool {
        
        var urlComponents = URLComponents(string: "https://streeteasydaily.s3.us-west-2.amazonaws.com/streeteasy3.json")

        urlComponents?.queryItems = []
        let url = urlComponents?.url
        
        if let url = url {
            
            // Create URL Request
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Get URLSession
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                // Fancy simplified way
                if error == nil {
                    do {
                        if data != nil {
//                            let json = try JSONSerialization.jsonObject(with: data!, options:[])
//                            print(json)
                            
                            let decodedResponse = try! XJSONDecoder().decode([Listings].self, from: data!)
                            
                            DispatchQueue.main.async {
                                self.listingsZ.append(contentsOf: decodedResponse)
                                
                                print("finished decoding first SE 3")
                                //self.getShortPriceZillow()
                                let indexStart = (self.listingsZ.count - decodedResponse.count)-1
                                for (index, listing) in self.listingsZ.enumerated() where index > indexStart {
                                //for listing in self.listingsZ {
                                    
                                    listing.coordinate = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
                                    //coord.locationCoordinate()
                                    
                                    let shortPrice = (Double(listing.price ?? 0))/1000
                                    if String(shortPrice).last! == "0" {
                                        listing.priceShort = String(format: "%.0f", shortPrice) + "K"
                                    } else {
                                        listing.priceShort = String(format: "%.1f", shortPrice) + "K"
                                    }
                                    
                                    //condition bedrooms, para cuando venga nulo el culo
                                    var listingRooms = 0
                                    if listing.bedroom == nil {
                                        listing.bedroom = ""
                                    }
                                }

                                self.getSEListings4() //get the rest of the json
                            }
                            
                            //just in case we get less than 5k listings. make siure to ghet store mgr
                            SKPaymentQueue.default().add(self.storeManager)
                            self.storeManager.getProducts(productIDs: self.productIDs)
                        }
                    }
                    catch {print(error)}
                }
            }
            // Start the Data Task
            dataTask.resume()
            return true
        } else {
            return false
        }
    }
    func getSEListings4() -> Bool {
        
        var urlComponents = URLComponents(string: "https://streeteasydaily.s3.us-west-2.amazonaws.com/streeteasy4.json")

        urlComponents?.queryItems = []
        let url = urlComponents?.url
        
        if let url = url {
            
            // Create URL Request
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Get URLSession
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                // Fancy simplified way
                if error == nil {
                    do {
                        if data != nil {
//                            let json = try JSONSerialization.jsonObject(with: data!, options:[])
//                            print(json)
                            
                            let decodedResponse = try! XJSONDecoder().decode([Listings].self, from: data!)
                            
                            if decodedResponse.count > 0 {
                                DispatchQueue.main.async {
                                    self.listingsZ.append(contentsOf: decodedResponse)
                                    let indexStart = (self.listingsZ.count - decodedResponse.count)-1
                                    print("finished decoding first SE 4")
                                    //self.getShortPriceZillow()
                                    for (index, listing) in self.listingsZ.enumerated() where index > indexStart {
                                    //for listing in self.listingsZ {
                                        
                                        listing.coordinate = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
                                        //coord.locationCoordinate()
                                        
                                        let shortPrice = (Double(listing.price ?? 0))/1000
                                        if String(shortPrice).last! == "0" {
                                            listing.priceShort = String(format: "%.0f", shortPrice) + "K"
                                        } else {
                                            listing.priceShort = String(format: "%.1f", shortPrice) + "K"
                                        }
                                        
                                        //condition bedrooms, para cuando venga nulo el culo
                                        var listingRooms = 0
                                        if listing.bedroom == nil {
                                            listing.bedroom = ""
                                        }
                                    }
                                
                                    self.getSEListings5() //get the rest of the json
                                    
                                }
                            }

                        }
                    }
                    catch {print(error)}
                }
            }
            // Start the Data Task
            dataTask.resume()
            return true
        } else {
            return false
        }
    }
    func getSEListings5() -> Bool {
        
        var urlComponents = URLComponents(string: "https://streeteasydaily.s3.us-west-2.amazonaws.com/streeteasy5.json")

        urlComponents?.queryItems = []
        let url = urlComponents?.url
        
        if let url = url {
            
            // Create URL Request
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Get URLSession
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                // Fancy simplified way
                if error == nil {
                    do {
                        if data != nil {
//                            let json = try JSONSerialization.jsonObject(with: data!, options:[])
//                            print(json)
                            
                            let decodedResponse = try! XJSONDecoder().decode([Listings].self, from: data!)
                            
                            if decodedResponse.count > 0 {
                                DispatchQueue.main.async {
                                 
                                    self.listingsZ.append(contentsOf: decodedResponse)
                                    let indexStart = (self.listingsZ.count - decodedResponse.count)-1
                                    
                                    print("finished decoding first SE 5")
                                    //self.getShortPriceZillow()
                                    for (index, listing) in self.listingsZ.enumerated() where index > indexStart {
                                    //for listing in self.listingsZ {
                                        
                                        listing.coordinate = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
                                        //coord.locationCoordinate()
                                        
                                        let shortPrice = (Double(listing.price ?? 0))/1000
                                        if String(shortPrice).last! == "0" {
                                            listing.priceShort = String(format: "%.0f", shortPrice) + "K"
                                        } else {
                                            listing.priceShort = String(format: "%.1f", shortPrice) + "K"
                                        }
                                        
                                        //condition bedrooms, para cuando venga nulo el culo
                                        var listingRooms = 0
                                        if listing.bedroom == nil {
                                            listing.bedroom = ""
                                        }
                                    }

                                    self.getSEListings6() //get the rest of the json
                                }
                            }
                            
                        }
                    }
                    catch {print(error)}
                }
            }
            // Start the Data Task
            dataTask.resume()
            return true
        } else {
            return false
        }
    }
    func getSEListings6() -> Bool {
        
        var urlComponents = URLComponents(string: "https://streeteasydaily.s3.us-west-2.amazonaws.com/streeteasy6.json")

        urlComponents?.queryItems = []
        let url = urlComponents?.url
        
        if let url = url {
            
            // Create URL Request
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Get URLSession
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                // Fancy simplified way
                if error == nil {
                    do {
                        if data != nil {
//                            let json = try JSONSerialization.jsonObject(with: data!, options:[])
//                            print(json)
                            
                            let decodedResponse = try! XJSONDecoder().decode([Listings].self, from: data!)
                            
                            if decodedResponse.count > 0 {
                                DispatchQueue.main.async {
                                    self.listingsZ.append(contentsOf: decodedResponse)
                                    
                                    print("finished decoding first SE 6")
                                    let indexStart = (self.listingsZ.count - decodedResponse.count)-1
                                    //self.getShortPriceZillow()
                                    for (index, listing) in self.listingsZ.enumerated() where index > indexStart {
                                    //for listing in self.listingsZ {
                                        
                                        listing.coordinate = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
                                        //coord.locationCoordinate()
                                        
                                        let shortPrice = (Double(listing.price ?? 0))/1000
                                        if String(shortPrice).last! == "0" {
                                            listing.priceShort = String(format: "%.0f", shortPrice) + "K"
                                        } else {
                                            listing.priceShort = String(format: "%.1f", shortPrice) + "K"
                                        }
                                        
                                        //condition bedrooms, para cuando venga nulo el culo
                                        var listingRooms = 0
                                        if listing.bedroom == nil {
                                            listing.bedroom = ""
                                        }
                                    }

                                    self.getSEListings7() //get the rest of the json
                                }
                            }
                            
                        }
                    }
                    catch {print(error)}
                }
            }
            // Start the Data Task
            dataTask.resume()
            return true
        } else {
            return false
        }
    }
    func getSEListings7() -> Bool {
        
        var urlComponents = URLComponents(string: "https://streeteasydaily.s3.us-west-2.amazonaws.com/streeteasy7.json")

        urlComponents?.queryItems = []
        let url = urlComponents?.url
        
        if let url = url {
            
            // Create URL Request
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Get URLSession
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                // Fancy simplified way
                if error == nil {
                    do {
                        if data != nil {
//                            let json = try JSONSerialization.jsonObject(with: data!, options:[])
//                            print(json)
                            
                            let decodedResponse = try! XJSONDecoder().decode([Listings].self, from: data!)
                            
                            if decodedResponse.count > 0 {
                                DispatchQueue.main.async {
                                    self.listingsZ.append(contentsOf: decodedResponse)
                                    self.resultsFetched = true
                                    
                                    print("finished decoding first SE 7")
                                    let indexStart = (self.listingsZ.count - decodedResponse.count)-1
                                    
                                    //self.getShortPriceZillow()
                                    for (index, listing) in self.listingsZ.enumerated() where index > indexStart {
                                    //for (listing) in self.listingsZ {
                                        
                                        listing.coordinate = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
                                        //coord.locationCoordinate()
                                        
                                        let shortPrice = (Double(listing.price ?? 0))/1000
                                        if String(shortPrice).last! == "0" {
                                            listing.priceShort = String(format: "%.0f", shortPrice) + "K"
                                        } else {
                                            listing.priceShort = String(format: "%.1f", shortPrice) + "K"
                                        }
                                        
                                        //condition bedrooms, para cuando venga nulo el culo
                                        var listingRooms = 0
                                        if listing.bedroom == nil {
                                            listing.bedroom = ""
                                        }
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                    catch {print(error)}
                }
            }
            // Start the Data Task
            dataTask.resume()
            return true
        } else {
            return false
        }
    }
    
    
    func getSEListings() -> Bool {
        
        var urlComponents = URLComponents(string: "https://streeteasydaily.s3.us-west-2.amazonaws.com/streeteasy.json")
        //var urlComponents = URLComponents(string: "https://github.com/naticio/Reny/blob/main/streeteasytemp.json")
        
        
        urlComponents?.queryItems = [
            //URLQueryItem(name: "datasetId", value: "5jfcFjGgewXHY843f"),
            //            URLQueryItem(name: "token", value: token),
        ]
        let url = urlComponents?.url
        
        if let url = url {
            
            // Create URL Request
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Get URLSession
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                // Fancy simplified way
                if error == nil {
                    
                    do {
                        if data != nil {
                            
                            //this is only needed to print the json as string
                            //                            let json = try JSONSerialization.jsonObject(with: data!, options:[])
                            //                            print("Received response")
                            //
                            //                            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            //                                // try to read out a string array
                            //                                let addresses = json["address"] as? [String]
                            //                            }
                            
                            //using IkigaJSON, supposedely 4x faster than foundation
                            //                            let decodedResponse = try! ZippyJSONDecoder().decode([Listings].self, from: data!)
                            
                            let decodedResponse = try! XJSONDecoder().decode([Listings].self, from: data!)
                            
                            // decode the json to an array of listings
                            //let decodedResponse = try! JSONDecoder().decode([Listings].self, from: data!)
                            
                            DispatchQueue.main.async {
                                self.listingsZ.append(contentsOf: decodedResponse)
                                self.resultsFetched = true
                                print("FETCHED 2ND RESULTS - 2ND CALL *******************")
                                
                                print(self.listingsZ.count)
                                print("added rest of json")
                                self.getShortPriceZillow()
                                
                                if self.filters == true {//we have to filter
                                    //self.getListingsFiltered(PriceMin: self.selectedPriceMin, PriceMax: self.selectedPriceMax, desiredBedrooms: self.selectedBedrooms)
                                }
                                
                            }
                            
                            SKPaymentQueue.default().add(self.storeManager)
                            self.storeManager.getProducts(productIDs: self.productIDs)
                            
                        }
                    }
                    catch {print(error)}
                }
                
                //rustic way to handle huge json
                
            }
            
            // Start the Data Task
            dataTask.resume()
            return true
        } else {
            return false
        }
    }
    
    func getSEListingsSerialization() -> Bool {
        
        var urlComponents = URLComponents(string: "https://streeteasydaily.s3.us-west-2.amazonaws.com/streeteasy.json")
        
        
        urlComponents?.queryItems = [
            //URLQueryItem(name: "datasetId", value: "5jfcFjGgewXHY843f"),
            //            URLQueryItem(name: "token", value: token),
        ]
        let url = urlComponents?.url
        
        if let url = url {
            
            // Create URL Request
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            //request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // Get URLSession
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                if error == nil {
                    
                    do {
                        if data != nil {
                            
                            //serialization baby!
                            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String:Any]]
                            
                            //make it an array
                            let first100Listings = json!.first!["data"] as? NSArray
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: first100Listings!, options: [])
                            let responseModel = try JSONDecoder().decode([Listings].self, from: jsonData)
                            
                            self.listingsZ = responseModel
                            
                            DispatchQueue.main.async {
                                //show listngs view
                                self.resultsFetched = true
                                
                                self.getShortPriceZillow()
                            }
                        }
                    }
                    catch {print(error)}
                }
                do {
                    
                }
                catch {print(error)}
            }
            // Start the Data Task
            dataTask.resume()
            return true
        } else {
            return false
        }
    }
    
    func getLandlordData() {
        
        var urlComponents = URLComponents(string: "https://data.cityofnewyork.us/resource/tesw-yqqr.json")
        
        urlComponents?.queryItems = [
            //URLQueryItem(name: "datasetId", value: "5jfcFjGgewXHY843f"),
            //            URLQueryItem(name: "token", value: token),
        ]
        let url = urlComponents?.url
        
        if let url = url {
            
            // Create URL Request
            let token = "F1vL3edT3QvnzhdDEd9RUlYIS"
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "X-Auth-Token")
            
            // Get URLSession
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                if error == nil {
                    
                    do {
                        if data != nil {
                            
                            let json = try JSONSerialization.jsonObject(with: data!, options:[])
                            print(json)
                            
                            let decodedResponse = try! JSONDecoder().decode([Building].self, from: data!)
                            self.buildings = decodedResponse
                        }
                    }
                    catch {print(error)}
                }
            }
            // Start the Data Task
            dataTask.resume()
        }
    }
    
    func getListingsFiltered(PriceMin: String, PriceMax: String, desiredBedrooms: Int) {
        
        var listingsF = [Listings]() //new array instance of listing
        
        var lowestPrice = 0
        var highestPrice = 1000000000
        
        if PriceMin == "Any" {lowestPrice = 0} else {lowestPrice = Int(PriceMin) ?? 0}
        if PriceMax == "Any" {highestPrice = 1000000000} else { highestPrice = Int(PriceMax) ?? 1000000000}
        
        //append the ones that match
        for listing in self.listingsZ {
            //condition location
            
            /*/no region selected. WHY? I will alwsy have a region!!!
            if self.region.center.latitude == 0 || self.region.center.longitude == 0 {
                //let listingPrice = Int(listing.price!.dropFirst())
                if Int(listing.price) >= lowestPrice && Int(listing.price) <= highestPrice {
                    //condition bedrooms
                    var listingRooms = 0
                    if listing.bedroom != nil {
                        listingRooms = Int(listing.bedroom!.prefix(1)) ?? 0
                    } else {
                        listingRooms = 0
                    }
                    
                    
                    if listingRooms >= desiredBedrooms {
                        //condition location
                        
                        var l = Listings()
                        l.address = listing.address!
                        l.neighborhood = listing.neighborhood!
                        l.zipcode = listing.zipcode!
                        l.latitude = listing.latitude
                        l.longitude = listing.longitude
                        l.bedroom = listing.bedroom
                        l.bath = listing.bath
                        
                        l.photos = listing.photos
                        l.video = listing.video
                        l.description = listing.description
                        l.new_listing = listing.new_listing
                        l.date_available = listing.date_available
                        l.open_house = listing.open_house
                        l.price = listing.price
                        
                        l.dishwasher = listing.dishwasher
                        l.washer_and_dryer = listing.washer_and_dryer
                        l.pets_allowed = listing.pets_allowed
                        l.live_in_super = listing.live_in_super
                        l.elevator = listing.elevator
                        l.url = listing.url
                        
                        //l.priceShort = listing.priceShort
                        //l.coordinate = listing.coordinate
                        
                        
                        listingsF.append(l)
                    }
                    
                }
            } else {
                //there is a regionselected
                if listing.latitude != nil {
                    
                    let listingRegion = CLLocationCoordinate2D(latitude: listing.latitude, longitude: listing.longitude)
                    
                    if self.checkRegion(location: self.region.center, contains: listingRegion, with: 10000){
                        
                        //condition price
                        //let listingPrice = Int(listing.price!.dropFirst())
                        if Int(listing.price) >= lowestPrice && Int(listing.price) <= highestPrice {
                            //condition bedrooms
                            var listingRooms = 0
                            if listing.bedroom != nil {
                                listingRooms = Int(listing.bedroom!.prefix(1)) ?? 0
                            } else {
                                listingRooms = 0
                            }
                            
                            if listingRooms >= desiredBedrooms {
                                //condition location
                                
                                var l = Listings()
                                l.address = listing.address!
                                l.neighborhood = listing.neighborhood!
                                l.zipcode = listing.zipcode!
                                l.latitude = listing.latitude
                                l.longitude = listing.longitude
                                l.bedroom = listing.bedroom
                                l.bath = listing.bath
                                
                                l.photos = listing.photos
                                l.video = listing.video
                                l.description = listing.description
                                l.new_listing = listing.new_listing
                                l.date_available = listing.date_available
                                l.open_house = listing.open_house
                                l.price = listing.price
                                
                                l.dishwasher = listing.dishwasher
                                l.washer_and_dryer = listing.washer_and_dryer
                                l.pets_allowed = listing.pets_allowed
                                l.live_in_super = listing.live_in_super
                                l.elevator = listing.elevator
                                l.url = listing.url
                                
                                l.priceShort = listing.priceShort
                                l.coordinate = listing.coordinate
                                
                                listingsF.append(l)
                            }
                        }
                    }
                }
                
            } //enf of big if*/
            
            if listing.latitude != nil {
                
                let listingRegion = CLLocationCoordinate2D(latitude: listing.latitude, longitude: listing.longitude)
                
                if self.checkRegion(location: self.region.center, contains: listingRegion, with: 2000){
                    
                    //condition price
                    //let listingPrice = Int(listing.price!.dropFirst())
                    if Int(listing.price) >= lowestPrice && Int(listing.price) <= highestPrice {
                        //condition bedrooms
                        var listingRooms = 0
                        if listing.bedroom != nil {
                            listingRooms = Int(listing.bedroom!.prefix(1)) ?? 0
                        } else {
                            listingRooms = 0
                        }
                        
                        if listingRooms >= desiredBedrooms {
                            //condition location
                            
                            var l = Listings()
                            l.address = listing.address!
                            l.neighborhood = listing.neighborhood!
                            l.zipcode = listing.zipcode!
                            l.latitude = listing.latitude
                            l.longitude = listing.longitude
                            l.bedroom = listing.bedroom
                            l.bath = listing.bath
                            
                            l.photos = listing.photos
                            l.video = listing.video
                            l.description = listing.description
                            l.new_listing = listing.new_listing
                            l.date_available = listing.date_available
                            l.open_house = listing.open_house
                            l.price = listing.price
                            
                            l.dishwasher = listing.dishwasher
                            l.washer_and_dryer = listing.washer_and_dryer
                            l.pets_allowed = listing.pets_allowed
                            l.live_in_super = listing.live_in_super
                            l.elevator = listing.elevator
                            l.url = listing.url
                            
                            l.priceShort = listing.priceShort
                            l.coordinate = listing.coordinate
                            
                            listingsF.append(l)
                        }
                    }
                }
            }
            
            
        }
        
        DispatchQueue.main.async {
            //self.listingsF = listingsF
            self.listingsFZ = listingsF
            self.filters = true
            self.getShortPriceZillow()
            
            
        }
        
        //        self.listingsF.removeAll() {
        //            //$0.new_listing == nil || $0.new_listing == ""
        //            Int($0.price) ?? 0 < lowestPrice || Int($0.price) ?? 0 > highestPrice
        //
        //        }
    }
    
    /*func addCoordinatesToListing() {
     //var counter = 0
     
     for (index, listing) in self.results!.listings.enumerated() {
     
     let address1 = listing.address ?? ""
     let address = address1 + ", " + listing.neighborhood + ", " + listing.city + ", " + listing.state + ", " + listing.zipcode
     print(address)
     
     var geocoder = CLGeocoder()
     geocoder.geocodeAddressString(address) { placemarks, error in
     let placemark = placemarks?.first
     let lat = placemark?.location?.coordinate.latitude
     let lon = placemark?.location?.coordinate.longitude
     print("Lat: \(lat), Lon: \(lon)")
     
     listing.lat = lat
     listing.lon = lon
     listing.fulladdress = address
     
     //asssign region to listing
     //listing.region = MKcoordinate region
     // listing.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat!, longitude: lon!) , span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
     
     
     var priceShort : String = listing.price.replacingOccurrences(of: ",", with: "", options: NSString.CompareOptions.literal, range: nil)
     priceShort = priceShort.replacingOccurrences(of: "$", with: "", options: NSString.CompareOptions.literal, range: nil)
     
     listing.price = priceShort
     
     let shortPrice = (Double(priceShort) ?? 0)/1000
     if String(shortPrice).last! == "0" {
     listing.priceShort = String(format: "%.0f", shortPrice) + "K"
     } else {
     listing.priceShort = String(format: "%.1f", shortPrice) + "K"
     }
     
     self.resultsFetched  = true
     
     }
     //}
     }
     }*/
    
    
    func getShortPriceZillow() {
        //var counter = 0
        
        //for (index, listing) in self.listingsZ!.enumerated() {
        
        /*if self.filters == true && self.listingsFZ != nil {
            for listing in self.listingsFZ! {
                //assign coordinate
                //let coord = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
                
                listing.coordinate = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
                //coord.locationCoordinate()
                
                //                let removeChr = listing.price!.dropFirst()
                //                let listingPrice = Int(removeChr.replacingOccurrences(of: ",", with: ""))
                
                let shortPrice = (Double(listing.price ?? 0))/1000
                if String(shortPrice).last! == "0" {
                    listing.priceShort = String(format: "%.0f", shortPrice) + "K"
                } else {
                    listing.priceShort = String(format: "%.1f", shortPrice) + "K"
                }
            }
        } else {
            for listing in self.listingsZ {
                //assign coordinate
                //let coord = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
                
                listing.coordinate = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
                //coord.locationCoordinate()
            
                
                //                let removeChr = listing.price!.dropFirst()
                //                let listingPrice = Int(removeChr.replacingOccurrences(of: ",", with: ""))
                
                let shortPrice = (Double(listing.price ?? 0))/1000
                if String(shortPrice).last! == "0" {
                    listing.priceShort = String(format: "%.0f", shortPrice) + "K"
                } else {
                    listing.priceShort = String(format: "%.1f", shortPrice) + "K"
                }
                
                //condition bedrooms, para cuando venga nulo el culo
                var listingRooms = 0
                if listing.bedroom == nil {
                    listing.bedroom = ""
                }
            }
        }*/
        
        for listing in self.listingsZ {
            //assign coordinate
            //let coord = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
            
            listing.coordinate = Coordinate(latitude: listing.latitude, longitude: listing.longitude)
            //coord.locationCoordinate()
        
            
            //                let removeChr = listing.price!.dropFirst()
            //                let listingPrice = Int(removeChr.replacingOccurrences(of: ",", with: ""))
            
            let shortPrice = (Double(listing.price ?? 0))/1000
            if String(shortPrice).last! == "0" {
                listing.priceShort = String(format: "%.0f", shortPrice) + "K"
            } else {
                listing.priceShort = String(format: "%.1f", shortPrice) + "K"
            }
            
            //condition bedrooms, para cuando venga nulo el culo
            var listingRooms = 0
            if listing.bedroom == nil {
                listing.bedroom = ""
            }
        }
    }
    
    
    func getListingStatus() {
        
        //        for listing in self.listingsZ! {
        //
        //        }
        
        //        let db = Firestore.firestore()
        //
        //        let leads = db.collection("leads")
        //
        //        let query = leads
        //            .whereField("status", isEqualTo: "Pending Application")
        //            .whereField("status", isEqualTo: "Accepted Application")
        //
        //            .addSnapshotListener { snapshot, error in
        //                if error == nil {
        //                    //var leads = [Matches]() //empty array of user/matches instances
        //                    for doc in snapshot!.documents {
        //                        listingsZ
        //                    }
        //                }
    }
    
    //MARK: - map functions
    func reconcileLocation(location: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                self.coordinate = coordinate
                self.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.isLoading = false
            }
        }
    }
    
    func checkRegion(location: CLLocationCoordinate2D, contains childLocation: CLLocationCoordinate2D, with radius: Double)-> Bool {
        let region = CLCircularRegion(center: location, radius: radius, identifier: "SearchId")
        return region.contains(childLocation)
    }
    
    func clear() {
        isLoading = true
    }
    
    func checkLogin() {
        
        if Auth.auth().currentUser == nil {
            loggedIn = false
            //self.userDataCompletion = false
        } else {
            //try! Auth.auth().signOut()
            loggedIn = true
            
            //get it only once
            
            //why get this shit?
            //            if UserDefaults.standard.string(forKey: "phone") == nil {
            //                Task {
            //                    await getUserData()
            //                }
            //            }
        }
        //to check if user is logged in or not every time the app opens
        //loggedIn = Auth.auth().currentUser == nil ? false : true
        
        
        //CHECK IF USERR metadata has been FETCHED. if the user was already logged in from a previous session, we need to get their data in a separate call
        //
    }
    
    //retrieve user data for the first time
    func getUserData() async -> Void {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        //fetch user Data from firebase
        let db = Firestore.firestore()
        let ref = db.collection("users").document(Auth.auth().currentUser!.phoneNumber ??  "")
        
        ref.getDocument { snapshot, error in
            
            // Check there's no errors
            guard error == nil, snapshot != nil else {
                return
            }
            
            // Parse the data out and set the user meta data
            let data = snapshot!.data()
            //let user = UserServic.shared.user
            
            UserService.shared.user.name = data?["name"] as? String ?? ""
            UserService.shared.user.phone = data?["phone"] as? String ?? ""
            UserService.shared.user.total_earnings = data?["total_earnings"] as? Int ?? 0
            UserService.shared.user.total_spending = data?["total_spending"] as? Int ?? 0
            UserService.shared.user.leads_address = data?["leads_address"] as? [String] ?? []
            UserService.shared.user.current_application = data?["current_application"] as? String ?? ""
            UserService.shared.user.submitted_date = data?["submitted_date"] as? Date ?? Date()
            
            //"submitted_date" : Date(),
            
            print("break line after populating user")
            
            return
            //user.date = data?["phone"] as? Date ?? Date()
            
            //            DispatchQueue.main.async {
            //                self.userDataCompletion = true
            //            }
        }
    }
    
    
    func sortByPrice() {
        //TBD
    }
    
    //MARK: - PLAID
    
    /*func createLinkToken() {
     
     let currentUser = Auth.auth().currentUser
     
     guard let url = URL(string: "https://development.plaid.com/link/token/create"),
     let payload =
     """
     {
     "client_id" : \(Constants.plaidClientId),
     "secret" : \(Constants.plaidSecret),
     "user" : \(currentUser),
     "client_name" : "Reny",
     "products" : ["auth"],
     "country_codes" : "US",
     "language" : "en",
     }
     """
     .data(using: .utf8) else
     {
     return
     }
     
     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     request.addValue("3e6e2adcb4da2c53197c5bfbd2a552", forHTTPHeaderField: "x-api-key")
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     request.httpBody = payload
     
     URLSession.shared.dataTask(with: request) { (data, response, error) in
     guard error == nil else { print(error!.localizedDescription); return }
     guard let data = data else { print("Empty data"); return }
     
     if let str = String(data: data, encoding: .utf8) {
     print(str)
     }
     }.resume()
     }*/
    
    
}

extension MKCoordinateRegion: Equatable
{
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool
    {
        if lhs.center.latitude != rhs.center.latitude || lhs.center.longitude != rhs.center.longitude
        {
            return false
        }
        if lhs.span.latitudeDelta != rhs.span.latitudeDelta || lhs.span.longitudeDelta != rhs.span.longitudeDelta
        {
            return false
        }
        return true
    }
}

extension String {
    // formatting text for currency textField
    func currencyFormatting() -> String {
        if let value = Int(self) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            //            formatter.maximumFractionDigits = 2
            //            formatter.minimumFractionDigits = 0
            if let str = formatter.string(for: value) {
                return str
            }
        }
        return ""
    }
}




