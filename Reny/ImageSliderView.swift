//
//  ImageSliderView.swift
//  Reny
//
//  Created by Nat-Serrano on 11/16/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageSliderView: View {
    
    var images : [String]
    var homeVista : Bool
    
    var body: some View {
        TabView {
            if homeVista == true {
                ForEach(images, id: \.self) { item in
                    //code to compensate the ..webd erro from scrapper
                    //let jpg = item.replacingOccurrences(of: "..webp", with: ".jpg")
                    let img = item.replacingOccurrences(of: ".jpg", with: ".webp")
                    WebImage(url: URL(string: img ?? ""))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.top)
                        //.aspectRatio(UIImage(named: item!.size, contentMode: .fill)
                        //.scaledToFill()
                        .frame(width: 400, alignment: .center)
                        .cornerRadius(10)
                        .padding(10)
                    
                }
            } else {
                ForEach(images, id: \.self) { item in
                    //code to compensate the ..webd erro from scrapper
                    //let jpg = item.replacingOccurrences(of: "..webp", with: ".jpg")
                    let img = item.replacingOccurrences(of: ".jpg", with: ".webp")
                    WebImage(url: URL(string: img ?? ""))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .edgesIgnoringSafeArea(.top)
                        //.aspectRatio(UIImage(named: item!.size, contentMode: .fill)
                        //.scaledToFill()
                        .frame(width: 400, alignment: .center)
                        .cornerRadius(10)
                        .padding(10)
                    
                }
            }

        }
        .tabViewStyle(PageTabViewStyle())
    }
}

//struct ImageSlider_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageSliderView()
//            .previewLayout(.fixed(width: 400, height: 300))
//    }
//}
