//
//  LocalSearchViewData.swift
//  Reny
//
//  Created by Nat-Serrano on 11/23/21.
//

import Foundation
import MapKit
import Combine

struct LocalSearchViewData: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    
    init(mapItem: MKMapItem) {
        self.title = mapItem.name ?? ""
        self.subtitle = mapItem.placemark.title ?? ""
    }
}
