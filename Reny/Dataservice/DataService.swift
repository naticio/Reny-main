//
//  DataService.swift
//  Reny
//
//  Created by Nat-Serrano on 5/25/22.
//
import Foundation

class DataService {
    
    static func getLocalData() -> [Listings] {
         
        // Parse local json file
        
        // Get a url path to the json file
        let pathString = Bundle.main.path(forResource: "mock_listings", ofType: "json")
        
        // Check if pathString is not nil, otherwise...
        guard pathString != nil else {
            return [Listings]()
        }
        
        // Create a url object
        let url = URL(fileURLWithPath: pathString!)
        
        do {
            // Create a data object
            let data = try Data(contentsOf: url)
            
            // Decode the data with a JSON decoder
            let decoder = JSONDecoder()
            
            do {
                
                let listingsData = try decoder.decode([Listings].self, from: data)
                
                
                // Return the recipes
                return listingsData
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
        
        return [Listings]()
    }
    
}
