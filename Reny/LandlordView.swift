//
//  Landlord.swift
//  Reny
//
//  Created by Nat-Serrano on 6/25/22.
//

import SwiftUI

struct LandlordView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        LazyVStack {
            if model.buildings != nil {
                ForEach(model.buildings!) { building in
                    HStack {
                        Text(building.housenumber ?? "")
                        Text(building.boroid ?? "")
                        Text(building.buildingid ?? "")
                        Text(building.lot ?? "")
                    }
                }
            }
        }
    }
        
    
        
}

struct Landlord_Previews: PreviewProvider {
    static var previews: some View {
        LandlordView()
    }
}
