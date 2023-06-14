//
//  UserService.swift
//  Reny
//
//  Created by Nat-Serrano on 11/26/21.
//


import Foundation
import Firebase
import FirebaseFunctions
import FirebaseAuth

class UserService {
    
    var user = User()
    
    static var shared = UserService()
    
    private init() {
        
    }
}

