//
//  LaunchLogicView.swift
//  Reny
//
//  Created by Nat-Serrano on 7/2/22.
//

import SwiftUI
import FirebaseAuth

//extension UserDefaults {
//    var welcomeScreenShown: Bool {
//        get {
//            return (UserDefaults.standard.value(forKey: "welcomeScreenShown9") as? Bool) ?? false
//        }
//        set {
//            UserDefaults.standard.setValue(newValue, forKey: "welcomeScreenShown9")
//        }
//    }
//}

struct LaunchLogicView: View {
    @EnvironmentObject var model: ContentModel
    @EnvironmentObject var purchaseManager: PurchaseManager
    //@EnvironmentObject var locModel: LocationModel
    //@StateObject var model: ContentModel
    
    
    var body: some View {
        
        if UserDefaults.standard.string(forKey: "welcomeScreens") == nil {
            NavigationView {
                TabView {
                    VStack {
                        Image("1_find_apt")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 500, alignment: .center)
                        Text("Reny lets you rent in NYC without paying exorbitant broker fees").font(.title)
                    }
                    
                    VStack {
                        Image("2_submit_application")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 500, alignment: .center)
                        Text("Just submit an application directly to the Landlord").font(.title)
                    }
                    
                    VStack {
                        Image("3_approved")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 500, alignment: .center)
                        Text("We'll make sure you're financially qualified").font(.title)
                    }
                    
                    VStack{
                        Image("4_sign_contract")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 500, alignment: .center)
                        Text("and then Sign a contract with the Landlord").font(.title)
                        
                        NavigationLink {
                            LaunchLogicView()
//                                .environmentObject(ContentModel())
//                                .environmentObject(LocationModel())
                            
                                .onOpenURL { url in
                                    print("Received URL: \(url)")
                                    Auth.auth().canHandle(url) // <- just for information purposes
                                }
                        } label: {
                            ZStack {
                                Rectangle().foregroundColor(.blue).frame(height: 40).cornerRadius(10)
                                Text("I got it! Let me search for my new apartment!").foregroundColor(.white)
                                
                            }
                            
                        }
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true)
                        .simultaneousGesture(TapGesture().onEnded{
                            UserDefaults.standard.set(true, forKey: "welcomeScreens")
                        })
                    }
                }
                .task {
                    if model.resultsFetched == false {
                        //model.getSEListings()
                        //await model.reload()
                        
                        model.getListingsFromFirebase()
                        
                        model.getSEListings1()
                    }
                    
                }
                //                .refreshable {
                //                    await model.reload()
                //                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }.navigationBarHidden(true)
                .navigationViewStyle(.stack)
            
        } else {
            if model.selectedView == "Search" {
                FilterView()
                //MARK: - FETCH THE RESULTS!
                    .task {
                        if (model.resultsFetched == false || model.listingsZ.count == 0) && UserDefaults.standard.string(forKey: "welcomeScreens") != nil { //add condition if tuesday or friday
                            //if model.resultsFetched == false && UserDefaults.standard.string(forKey: "welcomeScreens") != nil {
                            //model.getSEListings()
                            //await model.reload()
                            
                            model.getListingsFromFirebase()
                            
                            model.getSEListings1()
                        }
                    }
                //                    .refreshable {
                //                        await model.reload()
                //                    }
                ///LOCALIZATION SHIT
                /*
                    .onAppear() {
                        if locModel.authorizationState == .notDetermined {
                            //ask for user location
                            locModel.requestGeolocationPermission()
                        }
                        //            else if locModel.authorizationState == .authorizedAlways || locModel.authorizationState == .authorizedWhenInUse {
                        //
                        //                //do nothiong
                        //            }
                        
                    }
                 */
                
            } else if model.selectedView == "ListMap"{
                HomeViewZ()
                    .environmentObject(UserData())
                    .environmentObject(PlaidAPI())
                    .environmentObject(PurchaseManager())
                
            }
        }
        
        
        
    }
}

