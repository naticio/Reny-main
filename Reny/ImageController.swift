//
//  ImageController.swift
//  Secret0
//
//  Created by Nat-Serrano on 9/4/21.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

class ImageController: ObservableObject {
    
    @Published var unprocessedImage: UIImage? {
        didSet {
            displayedImage = unprocessedImage
        }
    }
    
    @Published var displayedImage: UIImage? //optional might be nil
    

   
}
