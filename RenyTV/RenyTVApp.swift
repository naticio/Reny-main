//
//  RenyTVApp.swift
//  RenyTV
//
//  Created by Nat-Serrano on 7/31/22.
//

import SwiftUI

@main
struct RenyTVApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
