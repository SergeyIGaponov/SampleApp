//
//  IAPManager.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import StoreKit

class IAPManager: NSObject{
    static let shared = IAPManager()
    static let productNotificationIdentifier = "IAPManagerProductIdentifier"
    static let productSKPaymentNotificationIdentifier = "productSKPaymentNotificationIdentifier"
    
    var products = [SKProduct]()
    var paymentQueue = SKPaymentQueue.default()
    
    private override init() {
    }
    
    public func setupPurchases(callback: @escaping (Bool)->()){
        if SKPaymentQueue.canMakePayments(){
            paymentQueue.add(self)
            callback(true)
            return
        }
        callback(false)
    }
    
    public func getProducts(){
        let identifiers: Set = [
            IAAProducts.oneMonth.getID,
            IAAProducts.oneYear.getID,
            IAAProducts.sixMonth.getID            
        ]
        
        let productRequest = SKProductsRequest(productIdentifiers: identifiers)
        productRequest.delegate = self
        productRequest.start()
    }
    
    public func priceStringFor(product: SKProduct) -> (String, NSDecimalNumber){
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return (numberFormatter.string(from: product.price) ?? "0", product.price)
    }
    
    public func purchase(productWith identifier: String){
        guard let product = products.filter({
            $0.productIdentifier == identifier
        }).first else {return}
    
        let payment = SKPayment(product: product)
        paymentQueue.add(payment)
    }
    
    public func restoredCompletedTransactions(){
        paymentQueue.restoreCompletedTransactions()
    }
}

extension IAPManager: SKPaymentTransactionObserver{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            switch transaction.transactionState{
            case .deferred:
                //подвешенное состояние
                break
            case .purchasing:
                //алерт покупки
                break
            case .failed:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPManager.productSKPaymentNotificationIdentifier), object: nil)
                fail(transaction: transaction)
            case .purchased:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPManager.productSKPaymentNotificationIdentifier), object: nil)
                complete(transaction: transaction)
            case .restored:
                restored(transaction: transaction)
            @unknown default:
                fail(transaction: transaction)
                print("unknown SKPaymentTransactionObserver")
            }
        }
    }
    
    private func fail(transaction: SKPaymentTransaction){
        if let transactionError = transaction.error as NSError?{
            if transactionError.code != SKError.paymentCancelled.rawValue{
                print("Ошибка транзакции \(transactionError.localizedDescription)")
            }
        }
        paymentQueue.finishTransaction(transaction)
    }
    
    private func complete(transaction: SKPaymentTransaction){
        checkValid()
        paymentQueue.finishTransaction(transaction)
    }
    
    public func checkValid(){
        let receiptValidator = ReceiptValidator()
        let result = receiptValidator.validateReceipt()
        
        switch result {
        case let .success(receipt):
            guard let purchases = receipt.inAppPurchaseReceipts else{
                UserDefaults.standard.set(false, forKey: UDID.subscribtion.getKey)
                return
            }
            
            for purchase in purchases{
                if purchase.productIdentifier == IAAProducts.oneMonth.getID{
                    if purchase.subscriptionExpirationDate?.compare(Date()) == .orderedDescending{
                        UserDefaults.standard.set(true, forKey: UDID.subscribtion.getKey)
                        //send notification
                        return
                    }
                }else{
                    if purchase.productIdentifier == IAAProducts.oneYear.getID{
                        if purchase.subscriptionExpirationDate?.compare(Date()) == .orderedDescending{
                            UserDefaults.standard.set(true, forKey: UDID.subscribtion.getKey)
                            //send notification
                            return
                        }
                    }else{
                        if purchase.productIdentifier == IAAProducts.sixMonth.getID{
                            if purchase.subscriptionExpirationDate?.compare(Date()) == .orderedDescending{
                                UserDefaults.standard.set(true, forKey: UDID.subscribtion.getKey)
                                //send notification
                                return
                            }
                        }
                    }
                }
            }
            
            UserDefaults.standard.set(false, forKey: UDID.subscribtion.getKey)
            
            
        case let .error(error):
            print(error.localizedDescription)
        }
    }
    
    private func restored(transaction: SKPaymentTransaction){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPManager.productSKPaymentNotificationIdentifier), object: nil)
        paymentQueue.finishTransaction(transaction)
        checkValid()
    }
}

extension IAPManager: SKProductsRequestDelegate{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        products.forEach { (product) in
            print(product.localizedTitle)
        }
        if products.count > 0{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPManager.productNotificationIdentifier), object: nil)
        }
    }
}
