//
//  PurchaseManager.swift
//  Reny
//
//  Created by Nat-Serrano on 1/26/23.
//
import Foundation
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {

    //private let productIds = ["APTRT.BlueSky.MonthlySubscription"]
    
//#if DEV
//    let productIDs = ["APTRT.Reny.financialCheck.dev", "APTRT.Reny.visit.dev"]
//#else
//    let productIDs = ["APTRT.Reny.financialCheck", "APTRT.Reny.visit"]
//#endif
    
    @Published var triggerPlaid = false
    @Published var triggerVisit = false

    @Published var products: [Product] = []
    @Published private var productsLoaded = false

    @MainActor
    func loadProducts(productIds: [String]) async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }

    @MainActor
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            // Successful purchase
            await transaction.finish()
            
            //reny code
            UserDefaults.standard.setValue(true, forKey: transaction.productID)
            if transaction.productID == self.products.first?.id {
                //trigger plaid link
                triggerPlaid = true
            } else {
                triggerVisit = true
                //productDidPurchased?()
            }
            
        case let .success(.unverified(transaction, error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            
            await transaction.finish()
            //reny code
            UserDefaults.standard.setValue(true, forKey: transaction.productID)
            if transaction.productID == self.products.first?.id {
                //trigger plaid link
                triggerPlaid = true
            } else {
                triggerVisit = true
                //productDidPurchased?()
            }
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
    }
}
