//
//  ContentView.swift
//  Reny
//
//  Created by Nat-Serrano on 11/12/21.
//

import SwiftUI
import CoreData
import MapKit
import SDWebImageSwiftUI
import StoreKit
import XCTest

struct HomeViewZ: View {
    @EnvironmentObject var model: ContentModel
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var plaid : PlaidAPI
    @EnvironmentObject var purchaseManager : PurchaseManager
    //@StateObject private var viewModel = DetailViewModel()
    //@EnvironmentObject var locModel: LocationModel
    
    //@EnvironmentObject var storeManager: StoreManager
    //@StateObject var storeManager = StoreManager() //new instance
   
    
    @State var searchInput: String = ""
    @State private var scrollViewID = UUID()
    
    @State var isMapShowing = true
    @State var selectedListing : Listings?
    var amounts = ["Any", "500", "1000", "1500", "2000","2500","3000","3500","4000","4500","5000","5500","6000","7000","8000","9000","10000","11000","12000","13000","14000","15000"]
    
    var beds = [0,1,2,3,4]
    
    @State private var rotateDegree : CGFloat = 0
    
    @State var feedbackModal = false
    //
    //    @State private var dishwasherPressed : Bool = false
    //    @State private var washerAndDryerPressed : Bool = false
    //    @State private var elevatorPressed : Bool = false
    
    @State var texts = ["Loading...", "Find an Apartment you like", "Send an application to the Landlord", "We'll approve you in secs baby!"]
    @State var textIndex : Int = 0
    @State var textContent: String = "Find the Apartment you like"
    
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
    
    
    
#if DEV
    let productIDs = ["APTRT.Reny.financialCheck.dev"]
#else
    let productIDs = ["APTRT.Reny.financialCheck"]
#endif
    //
    //    #if DEV
    //    let productIDs = ["APTRT.Reny.financialCheck.dev"]
    //    #else
    //    let productIDs = ["APTRT.Reny.financialCheck"]
    //    #endif
    
    //locations computed property
    var listings:[AnnotatedItem] {
        var annotations = [AnnotatedItem]() //markers in the map!
        
        //Create a set of annotations from our list of businesses
        for listing in model.listingsZ {
            
            //IF BUSINESS has lat/long create mkpoint annotation for it
            //create a new annotation
            let a = AnnotatedItem(name: listing.address ?? "", coordinate: .init(latitude: listing.latitude, longitude: listing.longitude))
            
            annotations.append(a)
        }
        return annotations
    }
    
    var body: some View {
        
        NavigationView {
            
            //if model.resultsFetched == false {
            if model.listingsZ.count == 0 { //MARK: - loading screen
                
                VStack {
                    Spacer()
                    //introduction text
                    
                    //                    Text(texts[textIndex]).bold()
                    //                        .font(.title).id(textIndex)
                    //                        .onAppear(perform: {
                    //                            next()
                    //                        })
                    
                    Text("Loading...").bold().font(.title)
                    
                    
                    //logo
                    Image("reny")
                        .rotationEffect(.degrees(rotateDegree))
                        .onAppear(perform: {
                            withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: false)) {
                                self.rotateDegree = 360
                            }
                        })
                    
                    Text("Reny").bold()
                        .font(.title)
                    Text("Rent in NYC without broker fees")
                    
                    Spacer()
                }
            }
            else {
                //MARK: - show listings
                if !isMapShowing {
                    
                    //if filter is on then show filtered listings
                    //show list
                    VStack {
                        //header listings
                        Group{
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color.white)
                                //.cornerRadius(5)
                                    .frame(height: 30)
                                
                                HStack {
#if DEV
                                    Text("DEVELOPMENT")
#endif
                                    Spacer()
                                    
                                    //button switch to filter
                                    /*Button {
                                     model.selectedView = "Search" //to trigger launchlogic
                                     //FilterView()
                                     //.navigationBarHidden(true)
                                     } label: {
                                     Image(systemName: "magnifyingglass")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(width: 30, height: 30, alignment: .center)
                                     }.padding(.horizontal, 10).padding(.top).padding(.bottom,0)*/
                                    
                                    //button to show map
                                    Button {
                                        self.isMapShowing = true
                                    } label: {
                                        Image(systemName: "map")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30, alignment: .center)
                                    }.padding(.horizontal, 10).padding(.top).padding(.bottom,0)
                                    
                                    //sort
                                    Button {
                                        //show menu
                                        Menu("Sort") {
                                            //Button("Sort by price", action: )//)
                                            
                                        }
                                    } label: {
                                        Image(systemName: "arrow.up.arrow.down")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30, alignment: .center)
                                    }
                                    
                                    
                                }.padding()
                            }.padding(.top).padding(.bottom,0)
                        }
                        
                        ScrollViewReader {ProxyReader in
                            ScrollView(.vertical, showsIndicators: false, content: {
                                
                                //Listings NO filters
                                if model.filters == false || model.filters == nil {
                                    LazyVStack {
                                        ForEach(model.listingsZ) { listing in
                                            NavigationLink(destination:
                                                            ListingDetailView(listing: listing)
                                                                
                                                            )
                                            {
                                                VStack {
                                                    
                                                    //if listing.photos?[0] != "" ||  listing.photos?[0] != nil {
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
                                                    ScrollViewInfo(listing: listing)
                                                    
                                                }
                                            }.buttonStyle(PlainButtonStyle())
                                                .environmentObject(ContentModel())
                                        }
                                        
                                    }
                                    .id("SCROLL_TO_TOP")
                                    .background(Color(.systemGroupedBackground))
                                } else {//Listings with filters
                                    LazyVStack {
                                        ForEach(filteredAnnotations) { listing in
                                            NavigationLink(destination: ListingDetailView(listing: listing)
                                                           
                                                .environmentObject(purchaseManager)){
                                                VStack {
                                                    
                                                    //if listing.photos?[0] != "" ||  listing.photos?[0] != nil {
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
                                                    ScrollViewInfo(listing: listing)
                                                    
                                                }
                                            }.buttonStyle(PlainButtonStyle())
                                                .environmentObject(ContentModel())
                                        }
                                        
                                    }
                                    .id("SCROLL_TO_TOP")
                                    .background(Color(.systemGroupedBackground))
                                }
                                
                            })//scroll view
                            //to recreate the veiw from scratch
                            .id(self.scrollViewID)
                            
                        }
                        
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .ignoresSafeArea()
                }
                else {  //MARK: -  show Map
                    ZStack(alignment: .top) {
                        MapViewiOS15(purchaseManager: purchaseManager)
                            .ignoresSafeArea()
                        
                        //MARK: - SEARCH filters - rectangle overlay with options
                        Group {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color.white)
                                    .cornerRadius(5)
                                    .frame(height: 48)
                                
                                HStack {
                                    
                                    //Price
                                    HStack {
                                        Image(systemName: "dollarsign.circle.fill")
                                        
                                        //price Max
                                        Picker("", selection: $model.selectedPriceMax) {
                                            ForEach(amounts, id: \.self) {
                                                Text($0).font(.caption)
                                            }
                                        }
                                        .onTapGesture {
                                            model.filters = true
                                            if model.selectedPriceMax != "Any" && model.selectedPriceMin != "Any" {
                                                if let min = Int(model.selectedPriceMin), let max =  Int(model.selectedPriceMax) {
                                                    // do something with goalOne
                                                    if min > max {
                                                        model.selectedPriceMax = "Any"
                                                    }
                                                }
                                            }
                                            //HomeViewZ()
                                        }
                                        
                                    }
                                    
                                    //bedroomms
                                    HStack {
                                        Image(systemName: "bed.double.fill")
                                        Picker("", selection: $model.selectedBedrooms) {
                                            ForEach(beds, id: \.self) {
                                                Text(String($0) + "+").font(.caption)
                                            }
                                        }
                                        .onTapGesture {
                                            model.filters = true
                                            //HomeViewZ()
                                        }
                                        
                                    }
                                    
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
                                    .padding(2)
                                    
                                    
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
                                    .padding(2)
                                    
                                    
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
                                    .padding(2)
                                    
                                    //
                                    //                                        //doorman
                                    //                                        HStack {
                                    //                                            Image(systemName: "bed.double.fill")
                                    //                                            .onTapGesture {
                                    //                                                model.filters = true
                                    //                                                //HomeViewZ()
                                    //                                            }
                                    //                                        }.padding()
                                    
                                    
                                    //Spacer()
                                    //button switch to map view
                                    Button {
                                        self.isMapShowing = false
                                    } label: {
                                        Image(systemName: "circle.grid.3x3.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30, alignment: .center)
                                    }.padding()
                                    //button switch to filter
                                    /*
                                     Button {
                                     model.selectedView = "Search" //to trigger launchlogic
                                     //FilterView()
                                     //.navigationBarHidden(true)
                                     } label: {
                                     Image(systemName: "magnifyingglass")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(width: 30, height: 30, alignment: .center)
                                     }.padding()*/
                                    
                                }
                                

                            }
                        }
                        

                    }.navigationBarHidden(true)
                        .overlay(
                            Button(action: {
                                //show modal feedback
                                
                                //self.feedbackModal.toggle()
                                
                                EmailHelper.shared.sendEmail(subject: "Feedback...", body: "Tell us how we can help you", to: "nat.serrano@reny.app")
                                
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                    self.transitionShown.toggle()
//                                    self.viewShown.toggle()
//
//                                }
                                
                                
                            }, label: {
                                Image(systemName: "paperplane")
                                    .font(.system(size:40))
                                    .foregroundColor(.black)
                                    //.padding(0)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            })
                            .padding(.trailing)
                            //.padding(.bottom, getSafeArea().bottom == 0 ? 12 : 0) //this is an if statement
                            //.opacity(-scrollViewOffset > 450 ? 1 : 0)
                            //.animation(.easeInOut)
                            
                            //to show rejection transition

//                            .sheet(isPresented: $feedbackModal, content: {
//                                feedbackModalView()
//                            })
                            
                            //fixing at bottom left the floating rejection !!
                            , alignment: .bottomTrailing
                            
                        )
                }
                
            }
            
            
        }//.ignoresSafeArea()
        .navigationViewStyle(.stack)
        
        
    } //end of body
    
    //to make the little animation
    private func next() {
        var next = textIndex + 1
        if next == texts.count {
            next = 0
        }
        withAnimation(Animation.linear(duration: 0.5)) {
            textIndex = next
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.next()
        }
    }
    
}



//markers
struct AnnotatedItem: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct ScrollViewInfo: View {
    @EnvironmentObject var model: ContentModel
    @State var listing: Listings
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .center) {
                
                HStack {
                    
                    Text(listing.priceShort ?? String(listing.price ?? 0) ?? "0")
                        .foregroundColor(.blue)
                        .font(.headline)
                        .padding(.leading, 10)
                    
                }
                
                HStack {
                    Image(systemName: "location.fill")
                    Text(listing.address ?? "")
                }
                
                
                
                HStack {
                    Image(systemName: "bed.double.fill")
                    Text(listing.bedroom ?? "0")
                }
                HStack {
                    Image("toilet")
                        .resizable()
                        .frame(width: 40, height: 30, alignment: .center)
                    Text(listing.bath ?? "0")
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
                
            }
            .padding(.bottom, 10)
            
        }
    }
}

struct feedbackModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var feedback: String = ""
    
    var body: some View {
        VStack{
            
            
            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                
                //TextEditor(text: $taskItem!.detail.toUnwrapped(defaultValue: "")) //to prevent coredata issue optional!
                
                TextEditor(text: $feedback)
                .multilineTextAlignment(.leading)
                  .font(.body)
                  //.focused($isFocused, equals: true)
                
                if feedback.isEmpty {
                          TextField("Tell us what you think about the app", text: $feedback)
                            .disabled(true) // don't allow for it to be tapped
                }
                

            }
            .padding(.horizontal, 30)
            .padding(.vertical, 30)
            
            Button {
                //dismiss view
                presentationMode.wrappedValue.dismiss()
            } label: {
                ZStack {
                    Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                    Text("Send").font(.title).foregroundColor(.white)
                }
            }
        }

        
    }
}



//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeViewZ()
//    }
//}
