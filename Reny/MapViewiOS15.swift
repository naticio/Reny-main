//
//  MapViewiOS15.swift
//  Reny
//
//  Created by Nat-Serrano on 11/21/21.
//

import SwiftUI
import MapKit
import StoreKit
import GoogleMobileAds

struct Place: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct MapViewiOS15: View {
    @EnvironmentObject var model: ContentModel
    //@StateObject private var viewModel = DetailViewModel()
    @StateObject private var mapSearch = MapSearch()
    //var locationResult : MKLocalSearchCompletion
    //@StateObject var storeManager: StoreManager //in app purchases
    //@StateObject var storeManager: StoreManager
    @StateObject var purchaseManager: PurchaseManager
    //@EnvironmentObject var locModel: LocationModel
    
#if DEV
    let productIDs = [
        "APTRT.Reny.financialCheck.dev",
        "APTRT.Reny.visit.dev"]
#else
    let productIDs = ["APTRT.Reny.financialCheck", "APTRT.Reny.visit"]
#endif
    
    
    ///Returns the  `visibleAnnotations` that are within the `region`
    var visibleAnnotations: [Listings]{
        //Your filter code
        
        model.listingsZ.filter({
            $0.coordinate!.locationCoordinate().isWithinRegion(region: model.region)
        })
        
    }
    
    var filteredAnnotations: [Listings]{
        //Your filter code
        
        var lowestPrice = 0.0
        var highestPrice = 1000000000.0
        
        if model.selectedPriceMin == "Any" {lowestPrice = 0.0} else {lowestPrice = Double(model.selectedPriceMin) ?? 0.0}
        if model.selectedPriceMax == "Any" {highestPrice = 1000000000.0} else { highestPrice = Double(model.selectedPriceMax) ?? 1000000000.0}
        
        if model.dishwasher && model.washerAndDryer && model.elevator {
            return model.listingsZ.filter({
                $0.coordinate!.locationCoordinate().isWithinRegion(region: model.region) && $0.price >= lowestPrice && $0.price <= highestPrice && Int($0.bedroom?.prefix(1) ?? "") ?? 0 >= model.selectedBedrooms && $0.dishwasher == true && $0.washer_and_dryer == true && $0.elevator == true
            })}
        if model.dishwasher && model.washerAndDryer && !model.elevator {
            return model.listingsZ.filter({
                $0.coordinate!.locationCoordinate().isWithinRegion(region: model.region) && $0.price >= lowestPrice && $0.price <= highestPrice && Int($0.bedroom?.prefix(1) ?? "") ?? 0 >= model.selectedBedrooms && $0.dishwasher == true && $0.washer_and_dryer == true
            })
        }
        if model.dishwasher && !model.washerAndDryer && model.elevator {
            return model.listingsZ.filter({
                $0.coordinate!.locationCoordinate().isWithinRegion(region: model.region) && $0.price >= lowestPrice && $0.price <= highestPrice && Int($0.bedroom?.prefix(1) ?? "") ?? 0 >= model.selectedBedrooms && $0.dishwasher == true && $0.elevator == true
            })
        }
        if !model.dishwasher && model.washerAndDryer && model.elevator {
            return model.listingsZ.filter({
                $0.coordinate!.locationCoordinate().isWithinRegion(region: model.region) && $0.price >= lowestPrice && $0.price <= highestPrice && Int($0.bedroom?.prefix(1) ?? "") ?? 0 >= model.selectedBedrooms && $0.washer_and_dryer == true && $0.elevator == true
            })
        }
        if !model.dishwasher && !model.washerAndDryer && model.elevator {
            return model.listingsZ.filter({
                $0.coordinate!.locationCoordinate().isWithinRegion(region: model.region) && $0.price >= lowestPrice && $0.price <= highestPrice && Int($0.bedroom?.prefix(1) ?? "") ?? 0 >= model.selectedBedrooms && $0.elevator == true
            })
        }
        if model.dishwasher && !model.washerAndDryer && !model.elevator {
            return model.listingsZ.filter({
                $0.coordinate!.locationCoordinate().isWithinRegion(region: model.region) && $0.price >= lowestPrice && $0.price <= highestPrice && Int($0.bedroom?.prefix(1) ?? "") ?? 0 >= model.selectedBedrooms && $0.dishwasher == true
            })
        }
        if !model.dishwasher && model.washerAndDryer && !model.elevator {
            return model.listingsZ.filter({
                $0.coordinate!.locationCoordinate().isWithinRegion(region: model.region) && $0.price >= lowestPrice && $0.price <= highestPrice && Int($0.bedroom?.prefix(1) ?? "") ?? 0 >= model.selectedBedrooms && $0.washer_and_dryer == true
            })
        }
        if !model.dishwasher && !model.washerAndDryer && !model.elevator {
            return model.listingsZ.filter({
                $0.coordinate!.locationCoordinate().isWithinRegion(region: model.region) && $0.price >= lowestPrice && $0.price <= highestPrice && Int($0.bedroom?.prefix(1) ?? "") ?? 0 >= model.selectedBedrooms
            })
        } else {
            return model.listingsZ.filter({
                $0.coordinate!.locationCoordinate().isWithinRegion(region: model.region) && $0.price >= lowestPrice && $0.price <= highestPrice && Int($0.bedroom?.prefix(1) ?? "") ?? 0 >= model.selectedBedrooms
            })
        }
        
    }
    
    @State private var products: [Product] = []
    
    var body: some View {
        
        //  ALL RESULTS / NO FILTERS
        if model.filters == false || model.filters == nil {
            Map(coordinateRegion: $model.region, showsUserLocation: true, annotationItems: visibleAnnotations.prefix(75)){ listing in
                // ... create a custom MapAnnotation
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: listing.latitude, longitude: listing.longitude)) {
                    NavigationLink {
                        ListingDetailView(listing: listing)
                        //.navigationBarHidden(true)
                    } label: {
                        PlaceAnnotationView(title: listing.priceShort ?? "")
                    }
                }
            }

            
        } else { //RESULTS FILTERED
            if mapSearch.searchTerm.isEmpty || model.region.center.latitude == 0 { //filters but MAPSEARCH TERM is empty
                Map(coordinateRegion: $model.region, showsUserLocation: true, annotationItems: filteredAnnotations.prefix(150)) { listing in
                    // ... create a custom MapAnnotation
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: listing.latitude, longitude: listing.longitude)) {
                        NavigationLink {
                            ListingDetailView(listing: listing)
                            //.navigationBarHidden(true)
                        } label: {
                            PlaceAnnotationView(title: listing.priceShort ?? "")
                        }
                    }
                }
                .onDisappear {
                    model.clear()
                }

            } else {
                Map(coordinateRegion: $model.region, showsUserLocation: true, annotationItems: filteredAnnotations.prefix(75)) { listing in
                    // ... create a custom MapAnnotation
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: listing.latitude, longitude: listing.longitude)) {
                        NavigationLink {
                            ListingDetailView(listing: listing)
                            //.navigationBarHidden(true)
                        } label: {
                            PlaceAnnotationView(title: listing.priceShort ?? "")
                        }
                    }
                }
                .onDisappear {
                    model.clear()
                }
                
            }
            
            //            .onAppear {
            //                viewModel.reconcileLocation(location: model.selectedLocation)
            //            }
            
        }
        
        
        
    }
    
    private func loadProducts() async throws {
        
#if DEV
    let productIds = [
        "APTRT.Reny.financialCheck.dev",
        "APTRT.Reny.visit.dev"]
        self.products = try await Product.products(for: productIds)
#else
    let productIds = ["APTRT.Reny.financialCheck", "APTRT.Reny.visit"]
        self.products = try await Product.products(for: productIds)
#endif
        
           
       }
}

struct PlaceAnnotationView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.callout)
                .padding(5)
                .background(Color(.blue))
                .foregroundColor(.white)
                .cornerRadius(10)
            
        }
    }
}


extension MKCoordinateSpan: Equatable {
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
}

//extensioon from stackoverflow to check if binding region contains the annotation
extension CLLocationCoordinate2D{
    ///Check if the `coordinate` is within the `MKCoordinateRegion`
    func isWithinRegion(region: MKCoordinateRegion) -> Bool{
        var result = false
        //Get the upper and lower bounds of the latitude and longitude
        //center +/- span/2
        //divide by 2 because the center is half way through
        let latUpper = region.center.latitude + region.span.latitudeDelta/2
        let latLower = region.center.latitude - region.span.latitudeDelta/2
        let lonUpper = region.center.longitude + region.span.longitudeDelta/2
        let lonLower = region.center.longitude - region.span.longitudeDelta/2
        //If the coordinate is within the latitude and the longitude
        if self.latitude >= latLower && self.latitude <= latUpper{
            if self.longitude >= lonLower && self.longitude <= lonUpper{
                //It is within the region
                result = true
            }
        }
        
        return result
    }
}


//struct MapViewiOS15_Previews: PreviewProvider {
//    static var previews: some View {
//        MapViewiOS15()
//    }
//}
