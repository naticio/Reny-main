//
//  RenyApp.swift
//  Reny
//
//  Created by Nat-Serrano on 11/12/21.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import UIKit
import GoogleMobileAds
//import StoreKit



//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//    var window: UIWindow?
//
//}



class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow? //FROM PLAID
    
    
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        //FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        //Analytics.setAnalyticsCollectionEnabled(false)
        FirebaseApp.configure()
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        //FirebaseConfiguration.shared.setLoggerLevel(.min)
        print("SwiftUI_2_Lifecycle_PhoneNumber_AuthApp application is starting up. ApplicationDelegate didFinishLaunchingWithOptions.")
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("\(#function)")
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("\(#function)")
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        print("\(#function)")
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }
}

@main
struct RenyApp: App {
    
    //@StateObject var storeManager = StoreManager ()
    @StateObject var model = ContentModel()
    
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate//for google phone auth
    
#if DEV
    let productIDs = ["APTRT.Reny.financialCheck.dev", "APTRT.Reny.visit.dev"]
#else
    let productIDs = ["APTRT.Reny.financialCheck", "APTRT.Reny.visit"]
#endif
    //
    var body: some Scene {
        WindowGroup {

            LaunchLogicView()
                        .environmentObject(ContentModel())
                        //.environmentObject(LocationModel())
                        .onOpenURL { url in
                            print("Received URL: \(url)")
                            Auth.auth().canHandle(url) // <- just for information purposes
                        }
                
            }
        }
    }
