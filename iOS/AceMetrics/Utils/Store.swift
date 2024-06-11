//
//  Store.swift
//
//  Created by Vijayakumar B on 24/03/22.
//

//  AceMetrics
//
// Copyright (C) 2024 Vectoral Innovations (OPC) Pvt. Ltd
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation
import StoreKit
import SwiftUI

extension SKProduct {
    private static let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = true
            formatter.numberStyle = .currency
            return formatter
        }()

        var isFree: Bool {
            price == 0.00
        }

        var regularPrice: String {
            guard !isFree else {
                return ""
            }
            
            let formatter = SKProduct.formatter
            formatter.locale = priceLocale

            return formatter.string(from: price) ?? ""
        }
}

class Store : NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var products = [SKProduct]()
    @Published var transactionState: SKPaymentTransactionState?
    @Published var timeOut = false
    private var request: SKProductsRequest!
    private var invalidProductIdentifiers: [String] = []
    private weak var timer: Timer?
    private var completion: ()->Void = {}
    
    func getProducts(productIds: [String]) {
        products.removeAll()
        
        let request = SKProductsRequest(productIdentifiers: Set(productIds))
        request.delegate = self
        request.start()
        timeOut = false
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(requestWait), userInfo: nil, repeats: false)
    }
    
    @objc func requestWait() {
        if products.isEmpty {
            self.timeOut = true
        }
        
        timer?.invalidate()
        timer = nil
    }
    
    func getProduct(productId: String) -> SKProduct? {
        for product in products {
            if product.productIdentifier == productId {
                return product
            }
        }
        
        return nil
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            for product in response.products {
                DispatchQueue.main.async {
                    self.products.append(product)
                }
            }
        }
        
        timer?.invalidate()
        timer = nil
            
        if !response.invalidProductIdentifiers.isEmpty {
            invalidProductIdentifiers = response.invalidProductIdentifiers
        }
    }
    
    func purchaseProduct(product: SKProduct, completion: @escaping ()->Void) {
        transactionState = nil
        if SKPaymentQueue.canMakePayments() {
            self.completion = completion
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restoreProducts(completion: @escaping ()->Void) {
        transactionState = nil
        self.completion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
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
                completion()
            case .restored:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .restored
                completion()
            case .failed, .deferred:
                queue.finishTransaction(transaction)
                transactionState = .failed
                completion()
            default:
                queue.finishTransaction(transaction)
                completion()
            }
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
