//
//  LocationSearchView.swift
//  Reny
//
//  Created by Nat-Serrano on 11/23/21.
//

import SwiftUI

struct LocationSearchView: View {
    @EnvironmentObject var model: ContentModel
    //@StateObject private var viewModel = ContentViewModel()
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var mapSearch = MapSearch() //jnpdx
    //@StateObject private var viewModel = DetailViewModel()
    
    var body: some View {
        
        Form {
            Section {
                TextField("Address", text: $mapSearch.searchTerm)
            }
            Section {
                ForEach(mapSearch.locationResults, id: \.self) { location in
                    
                    Button {
                        //save value into a Mapsearch variable
                        model.selectedLocation = location //assigned the location to the content view
                        model.reconcileLocation(location: model.selectedLocation)
                        
                        presentationMode.wrappedValue.dismiss()
                        
                    } label: {
                        VStack(alignment: .leading) {
                            Text(location.title)
                            Text(location.subtitle)
                                .font(.system(.caption))
                        }
                    }
//                    NavigationLink(destination: Detail(locationResult: location)) {
//                        VStack(alignment: .leading) {
//                            Text(location.title)
//                            Text(location.subtitle)
//                                .font(.system(.caption))
//                        }
//                    }
                }
            }
        }
    }
}

struct LocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchView()
    }
}
