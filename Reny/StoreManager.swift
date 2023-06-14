//
//  StoreManager.swift
//  Reny
//
//  Created by Nat-Serrano on 3/26/22.
//

import Foundation
import StoreKit
import Firebase

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    //FETCH PRODUCTS
    var request: SKProductsRequest!
    
    @Published var triggerPlaid = false
    @Published var triggerVisit = false
    
    var productDidPurchased: (() -> Void)?

    //@Published var screenDis = true
    
    @Published var myProducts = [SKProduct]()
    
    func getProducts(productIDs: [String]) {
        print("Start requesting products ...")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Did receive response for IAP purchases")
        
        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                }
            }
        }
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }
    
    //HANDLE TRANSACTIONS
    @Published var transactionState: SKPaymentTransactionState?
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payment.")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .purchased
                
                //string == string
                if transaction.payment.productIdentifier == self.myProducts.first?.productIdentifier {
                    //trigger plaid link
                    triggerPlaid = true
                } else {
                    triggerVisit = true
                    productDidPurchased?()
                }

                
            case .restored:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .restored
                //screenDis = false
                UserDefaults.standard.set(false, forKey: "application_in_progress")
                
                
            case .failed, .deferred:
                print("Payment Queue Error: \(String(describing: transaction.error))")
                queue.finishTransaction(transaction)
                transactionState = .failed
                //screenDis = false
                UserDefaults.standard.set(false, forKey: "application_in_progress")
                
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func restoreProducts() {
        print("Restoring products ...")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}




/*class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @Published var myProducts = [SKProduct]()
    @Published var transactionState: SKPaymentTransactionState?
    
    var request: SKProductsRequest! //to start the fetching process.
    
    //As soon as we receive a response from App Store Connect, this function is called.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Did receive response")
        
        //If we are sure that we have received products, add these products to our myProducts array
        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                }
            }
        }
        
        //If for some reason our response contains product IDs that are invalid, we want to be notified. We use a corresponding for-in loop for this purpose as well.
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
    
    //sends a request to the Apple servers based on given product IDs.
    func getProducts(productIDs: [String]) {
        print("Start requesting products ...")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    //If it should happen that we get no response from the Apple servers but the request fails, we would like to be notified about this.
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }
    
    // We need to start the purchase process as soon as the user taps on the respective “Purchase” Button.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                transactionState = .purchased
            case .restored:
                transactionState = .restored
            case .failed, .deferred:
                transactionState = .failed
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    //To start a transaction, we implement a new function called “purchaseProducts” which accepts a SKProduct.
    func purchaseProduct(product: SKProduct) {
        //we make sure that the user can also make payments. This is not the case, for example, if parental control is set up.
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payment.")
        }
    }
    
    
}*/

