//
//  MapSearch.swift
//  Reny
//
//  Created by Nat-Serrano on 11/23/21.
//

import Foundation
import SwiftUI
import Combine
import MapKit

class MapSearch : NSObject, ObservableObject {
    @Published var locationResults : [MKLocalSearchCompletion] = []
    @Published var searchTerm = ""
    @Published var isVisible = false
    
    private var cancellables : Set<AnyCancellable> = []
    
    //private var searchCompleter = MKLocalSearchCompleter.ResultType([.address])
    private var searchCompleter = MKLocalSearchCompleter()
    private var currentPromise : ((Result<[MKLocalSearchCompletion], Error>) -> Void)?
    
    private var regionNYC = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.75773, longitude: -73.985708), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    override init() {
        super.init()
        
        searchCompleter.delegate = self
        //searchCompleter.region = MKCoordinateRegion(.world)
        searchCompleter.region = regionNYC
        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])
        
        $searchTerm
            //.debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main, options: nil)
            .removeDuplicates()
            .flatMap({ (currentSearchTerm) in
                self.searchTermToResults(searchTerm: currentSearchTerm)
            })
            .sink(receiveCompletion: { (completion) in
                //handle error
            }, receiveValue: { (results) in
                self.locationResults = results.filter{$0.subtitle.contains("New York")}
                //self.locationResults = results
            })
            .store(in: &cancellables)
    }
    
    func searchTermToResults(searchTerm: String) -> Future<[MKLocalSearchCompletion], Error> {
        Future { promise in
            self.searchCompleter.queryFragment = searchTerm
            self.currentPromise = promise
            self.isVisible = true
        }
    }
}

extension MapSearch : MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            currentPromise?(.success(completer.results))
            
        }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //could deal with the error here, but beware that it will finish the Combine publisher stream
        //currentPromise?(.failure(error))
    }
}

