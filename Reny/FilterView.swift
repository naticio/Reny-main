//
//  FilterView.swift
//  Reny
//
//  Created by Nat-Serrano on 11/21/21.
//

import SwiftUI
import Combine
import MapKit

struct FilterView: View {
    @EnvironmentObject var model: ContentModel
    @Environment(\.presentationMode) var presentationMode
    //@ObservedObject var locationService: LocationService //to search location
    //@StateObject var viewModel = DetailViewModel()
    @StateObject private var mapSearch = MapSearch() //jnpdx
    
    //@EnvironmentObject var locModel: LocationModel
    
    //@State var selectedLoc: MKLocalSearchCompletion?
    
    //@State var locationInput: String = ""
    @State private var price: Int = 0
    @State private var buttonPressedBeds = 0
    
    @State private var isPresented = false ///for new listings
    
    @State var showSection = true
    
    var amounts = ["Any", "500", "1000", "1500", "2000","2500","3000","3500","4000","4500","5000","5500","6000","7000","8000","9000","10000","11000","12000","13000","14000","15000"]
    
    @State  var selectedAmountMin = "Any"
    @State  var selectedAmountMax = "Any"
    @State  var selectedBedrooms = 0
    @State var showMoreFilters : Bool = false
    
    //MARK: - new variable for predictive search
    
    var body: some View {
        
        
        VStack {
            //MARK: - BUY/RENT
            HStack() {
                ZStack {
                    //                    RoundedRectangle(cornerRadius: 10)
                    //                    //.stroke(Color.blue, lineWidth: 1)
                    //                        .frame(width: 80, height: 40)
                    //                        .foregroundColor(Color.blue)
                    //                    Text("Rent").font(.title).foregroundColor(.white)
                    Image("reny_launch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100, alignment: .center)
                }
                
                
                //Text("Buy").font(.title)
            }.padding()
            
            
            //MARK: - LOCATION SEARCH
            VStack(alignment: .leading){
                //Form {
                Section {
                    TextField("Address", text: $mapSearch.searchTerm)
                        .textFieldStyle(.roundedBorder)
                        .cornerRadius(10)
                        .font(.headline)
                }.padding()
                
                //if self.showSection == true  {
                //if mapSearch.locationResults.count > 0 && mapSearch.isVisible == true {
                //show the section
                Section {
                    ForEach(mapSearch.locationResults, id: \.self) { location in
                        
                        if mapSearch.searchTerm != location.title {
                            Button {
                                //save value into a Mapsearch variable
                                model.selectedLocation = location
                                
                                //assigned the location to the content view
                                mapSearch.locationResults = []
                                
                                //                                withAnimation{
                                //                                        self.showSection.toggle()
                                //                                    }
                                //mapSearch.isVisible = false
                                model.reconcileLocation(location: model.selectedLocation) //MARK: I ASSIGN THE FILTER LOCATION HERE!!!
                                
                                mapSearch.searchTerm = location.title
                                
                                //presentationMode.wrappedValue.dismiss()
                                
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
                //}
                
            }.padding()
            
            
            //buttons bedrooms
            Group {
                //Hstack bedrooms
                HStack {
                    
                    Image(systemName: "bed.double.fill")
                    
                    ZStack {
                        Rectangle().frame(height: 40).cornerRadius(10)
                            .foregroundColor(selectedBedrooms == 0 ? Color.blue : Color.white)
                        Button {selectedBedrooms = 0} label: {Text("Any")
                                .accentColor(selectedBedrooms == 0 ? Color.white : Color.blue)
                        }
                    }
                    ZStack {
                        Rectangle().frame(height: 40).cornerRadius(10)
                            .foregroundColor(selectedBedrooms <= 1 ? Color.blue : Color.white)
                        Button {selectedBedrooms = 1} label: {Text("1")
                            //.foregroundColor(.white)}
                                .accentColor(selectedBedrooms <= 1 ? Color.white : Color.blue)
                            //.background(selectedBedrooms == 0 ? Color.blue : Color.white)
                        }
                    }
                    ZStack {
                        Rectangle().frame(height: 40).cornerRadius(10)
                            .foregroundColor(selectedBedrooms <= 2 ? Color.blue : Color.white)
                        Button {selectedBedrooms = 2} label: {Text("2")
                                .accentColor(selectedBedrooms <= 2 ? Color.white : Color.blue)
                        }
                    }
                    ZStack {
                        Rectangle().frame(height: 40).cornerRadius(10)
                            .foregroundColor(selectedBedrooms <= 3 ? Color.blue : Color.white)
                        Button {selectedBedrooms = 3} label: {Text("3")
                            //.foregroundColor(.white)}
                                .accentColor(selectedBedrooms <= 3 ? Color.white : Color.blue)
                            //                            .background(selectedBedrooms == 0 ? Color.blue : Color.white)
                            
                        }
                    }
                    ZStack {
                        Rectangle().frame(height: 40).cornerRadius(10)
                            .foregroundColor(selectedBedrooms <= 4 ? Color.blue : Color.white)
                        Button {selectedBedrooms = 4} label: {Text("4+")
                            //.foregroundColor(.white)}
                                .accentColor(selectedBedrooms <= 4 ? Color.white : Color.blue)
                            //                            .background(selectedBedrooms == 0 ? Color.blue : Color.white)
                            
                        }
                    }
                    //                    ZStack {
                    //                        Rectangle().frame(height: 40).cornerRadius(10)
                    //                            .foregroundColor(selectedBedrooms <= 5 ? Color.blue : Color.white)
                    //                        Button {selectedBedrooms = 5} label: {Text("5+")
                    //                            //.foregroundColor(.white)}
                    //                                .accentColor(selectedBedrooms <= 5 ? Color.white : Color.blue)
                    //                            //.background(selectedBedrooms == 0 ? Color.blue : Color.white)
                    //
                    //                        }
                    //                    }
                    
                }.padding()
            }
            
            //Price picker
            HStack{
                Text("Price Range")
                //Slider(value: $price, in: 0...1000000)
                
                Picker("Min", selection: $selectedAmountMin) {
                    ForEach(amounts, id: \.self) {
                        Text($0)
                    }
                }
                .onTapGesture {
                    if selectedAmountMax != "Any" {
                        if let min = Int(selectedAmountMin), let max =  Int(selectedAmountMax) {
                            // do something with goalOne
                            if min > max {
                                selectedAmountMax = "Any"
                            }
                        }
                    }
                }
                
                //price Max
                Picker("Max", selection: $selectedAmountMax) {
                    ForEach(amounts, id: \.self) {
                        Text($0)
                    }
                }
                .onTapGesture {
                    if selectedAmountMax != "Any" && selectedAmountMin != "Any" {
                        if let min = Int(selectedAmountMin), let max =  Int(selectedAmountMax) {
                            // do something with goalOne
                            if min > max {
                                selectedAmountMax = "Any"
                            }
                        }
                    }
                }
            }.padding()
            
            HStack{
                //dishwasher
                Button {
                    model.dishwasher.toggle()
                    if model.filters == false {
                        model.filters = true
                    } else {
                        //scenario that all other filters are NOT pressed EXCEPT this button
                        //if all other filters are not pressed and model.filters == true then model.filters =  false
                        if model.selectedPriceMin == "" && model.selectedPriceMax == "" && model.selectedBedrooms == -1 && model.filters == true {
                            model.filters = false
                        }
                    }
                } label: {
                    Image("dishwasher")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                }
                .overlay(model.dishwasher ? RoundedRectangle(cornerRadius: 1).stroke(.blue, lineWidth: 4): nil)
                .padding()
                
                
                //washer and dryer
                Button {
                    model.washerAndDryer.toggle()
                    if model.filters == false {
                        model.filters = true
                    } else {
                        //scenario that all other filters are NOT pressed EXCEPT this button
                        //if all other filters are not pressed and model.filters == true then model.filters =  false
                        if model.selectedPriceMin == "" && model.selectedPriceMax == "" && model.selectedBedrooms == -1 && model.filters == true {
                            model.filters = false
                        }
                    }
                } label: {
                    Image("washerAndDryer")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                }
                .overlay(model.washerAndDryer ? RoundedRectangle(cornerRadius: 3).stroke(.blue, lineWidth: 4): nil)
                .padding()
                
                
                //elevator
                Button {
                    model.elevator.toggle()
                    if model.filters == false {
                        model.filters = true
                    } else {
                        //scenario that all other filters are NOT pressed EXCEPT this button
                        //if all other filters are not pressed and model.filters == true then model.filters =  false
                        if model.selectedPriceMin == "" && model.selectedPriceMax == "" && model.selectedBedrooms == -1 && model.filters == true {
                            model.filters = false
                        }
                    }
                } label: {
                    Image("elevator")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                }
                .overlay(model.elevator ? RoundedRectangle(cornerRadius: 5).stroke(.blue, lineWidth: 4): nil)
                .padding()
            }.padding()
            
            
            //            Toggle(isOn: $showMoreFilters, label: {
            //                Text("Show More Filters")
            //            })
            
            Spacer()
            //MARK: - SEARCH BUTTON
            
            ZStack {
                Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10).padding(.horizontal,20)
                Button {
                    
                    //assign the value of sleected values in memory
                    model.selectedBedrooms = selectedBedrooms
                    model.selectedPriceMin = selectedAmountMin
                    model.selectedPriceMax = selectedAmountMax
                    
                    //                    if mapSearch.searchTerm.isEmpty && locModel.authorizationState == .notDetermined{
                    //                        //default location without user location NYC city
                    //                        model.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.75773, longitude: -73.985708), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                    //                    } else {
                    //                        //give it user location
                    //                        if  mapSearch.searchTerm.isEmpty && (locModel.authorizationState == .authorizedAlways || locModel.authorizationState == .authorizedWhenInUse){
                    //                            model.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locModel.userLocation!.coordinate.latitude, longitude: locModel.userLocation!.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                    //                        } else {
                    //                            if model.region.center.latitude == 0 {
                    //                                model.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.75773, longitude: -73.985708), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                    //                            }
                    //                        }
                    //                    }
                    
                    if mapSearch.searchTerm.isEmpty {
                        //default location without user location NYC city
                        model.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.75773, longitude: -73.985708), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    }
                    
                    //if filters selected the model.filters == true
                    if selectedBedrooms == 0 && selectedAmountMin == "" && selectedAmountMax == "" && mapSearch.searchTerm.isEmpty {
                        model.filters = false
                    } else {
                        model.filters = true //a filter was selected
                        //get those fuckers filtered here if I already have listings decoded
                        if model.listingsFZ != nil {
                            //model.getListingsFiltered(PriceMin: selectedAmountMin, PriceMax: selectedAmountMax, desiredBedrooms: selectedBedrooms)
                        }
                        
                    }
                    
                    //self.presentationMode.wrappedValue.dismiss()
                    model.selectedView = "ListMap" //to trigger launchlogic
                } label: {
                    Text("Search").foregroundColor(.white)
                }
            }.padding()
            
            //MARK: - TRANSFER LEASE
            ZStack {
//                Rectangle().foregroundColor(.green).frame(height: 40).cornerRadius(10)
                Button {
                    //publishListing
                    self.isPresented.toggle()
                } label: {
                    Text("Transfer your lease and make money").foregroundColor(.black).font(.subheadline).underline().bold()
                }
                .fullScreenCover(isPresented: $isPresented, content: {
                    PublishListing.init(page: 0)
                })
                
            }
            
            Spacer()
        }
        .onAppear() {
            if model.selectedBedrooms != -1 {selectedBedrooms = model.selectedBedrooms}
            if model.selectedPriceMin != "Any" {selectedAmountMin = model.selectedPriceMin}
            if model.selectedPriceMax != "Any" {selectedAmountMax = model.selectedPriceMax}
        }
        
        
        
        
    }
}



struct Detail : View {
    var locationResult : MKLocalSearchCompletion
    @EnvironmentObject var viewModel: ContentModel
    
    struct Marker: Identifiable {
        let id = UUID()
        var location: MapMarker
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                Text("Loading...")
            } else {
                Map(coordinateRegion: $viewModel.region,
                    annotationItems: [Marker(location: MapMarker(coordinate: viewModel.coordinateForMap))]) { (marker) in
                    marker.location
                }
            }
        }.onAppear {
            viewModel.reconcileLocation(location: locationResult)
        }.onDisappear {
            viewModel.clear()
        }
        .navigationTitle(Text(locationResult.title))
    }
}

//struct FilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterView(locationInput: "Upper West Side")
//    }
//}
