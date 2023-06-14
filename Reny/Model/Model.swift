//
//  Model.swift
//  Reny
//
//  Created by Nat-Serrano on 11/13/21.
//

import Foundation
import MapKit
import SwiftUI


class Results: Decodable {
    var listings = [Listings]()
}
//
//class listingsPage: Decodable { //to do serialization or pagination
//    var page : Int = 0
//    var data = [Listings]()
//}


 
class Listings: Codable, Identifiable, ObservableObject {
    var address : String?
    var neighborhood: String?
    var zipcode : String?
    var latitude: Double = 0
    var longitude: Double = 0
    var bedroom: String?
    var bath: String?
    
    var photos: [String]?
    var video: String? //can be null
    var description: String?
    var new_listing: Int?
    var date_available: String?
    var open_house : [String]? //can be null
    var price: Double = 0.0
    
    var dishwasher: Bool = false
    var washer_and_dryer: Bool = false
    var pets_allowed: Bool = false
    var live_in_super: Bool = false
    var elevator: Bool?
    var url: String?
    var listed_by: String?
    var listed_by_url: String?
    var floor_plan: String?
    
    //var yearBuilt: Int?
    //var homeStatus: String?
    //var livingArea: Int?

    var priceShort: String?
    var coordinate: Coordinate?
}

struct AddressObj: Decodable {
    var streetAddress: String?
    var city: String?
    var state: String?
    var zipcode: String?
    var neighborhood: String?
//    var community: String?
//    var subdivision: String?
}

class Building: Decodable, ObservableObject, Identifiable {
    var registrationid : String?
    var buildingid: String?
    var boroid: String?
    var boro: String?
    var housenumber: String?
    var lowhousenumber: String?
    var streetname: String?
    var streetcode: String?
    var zip: String?
    var block: String?
    var lot: String?
    var bin: String?
    var communityboard: String?
    var lastregistrationdate: String?
    var registrationenddate: String?
    
    /*
        "registrationid": "911736",
        "buildingid": "917485",
        "boroid": "4",
        "boro": "QUEENS",
        "housenumber": "196-64",
        "lowhousenumber": "196-64",
        "highhousenumber": "196-64",
        "streetname": "69 AVENUE",
        "streetcode": "14490",
        "zip": "11365",
        "block": "7117",
        "lot": "401",
        "bin": "4459705",
        "communityboard": "8",
        "lastregistrationdate": "2022-02-09T00:00:00.000",
        "registrationenddate": "2022-09-01T00:00:00.000"
     */

}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double

    func locationCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude,
                                      longitude: self.longitude)
    }
}

struct Agent: Decodable {
    var name: String?
    var phone: String?
    var image: String?
}

struct Images: Decodable, Hashable {
    var image: String?
}

class User {
    var id: String = ""
    var name: String = ""
    var phone: String = ""
    var total_earnings: Int = 0
    var total_spending: Int = 0
    var leads_address: [String] = []
    var leads: [Leads]?
    var current_application: String = ""
    var submitted_date = Date()
}

struct Leads {
    var address : String = ""
    var name: String = ""
    var phone: String = ""
}

struct LastRun: Codable {
    var data : DataResult
}

struct DataResult: Codable {
    var defaultDatasetId : String = ""
}



//let dummyListing = Listings(
//
//)

//name = "47 w 75th st",
//                                 neighborhood = "Upper West Side",
//                                 url = "",
//                                 price = "2800",
//                                 city = "New York",
//                                 state = NY,
//                                 zipcode = "10023",
//                                 bedrooms "1",
//                                 bathrooms = "1",
//                                 //agents: [Agent]?,
//                                 //images: [Images]?,
//                                 address = "47 w 75th st",
//                                 var lat = 40.779240,
//                                 var lon = -73.976450,
//                                 var fulladdress = "47 w 75th st, Upper West Side, New York, NY, 10023"))
