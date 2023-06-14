//
//  LinkView.swift
//  Reny
//
//  Created by Nat-Serrano on 12/3/21.
//

import Foundation
import SwiftUI
import LinkKit

struct LinkView: View {
    //@ObservedObject var plaid = PlaidAPI()
    //@StateObject var plaid = PlaidAPI() //this is the line that is working!
    @EnvironmentObject var plaid : PlaidAPI
    @EnvironmentObject var model: ContentModel
    
//    @EnvironmentObject var viewRouter: ViewRouter
//    @EnvironmentObject var userData: UserData
    
    var body: some View {
        Group {
            if plaid.hasLoaded {
                LinkController(configuration: .linkToken(plaid.vc.createLinkTokenConfiguration()))
            }
        }.onAppear(){
            self.plaid.setToken()
        }
        .onDisappear(){ //do something here, show a new screenView that can be dismissed
            if (plaid.vc.PladFlowFinishedWithAccessToken){
                print("set up = true")
                
                //show sentAppView
                //SentApplication()
                
                //plaid.vc.setAccessToken(publicToken: plaid.vc.publicToken)
            }
        }
    }
    
}
