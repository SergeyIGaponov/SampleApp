//
//  BanerTryProViewController.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit

class BanerTryProViewController: UIViewController {
    
    @IBOutlet weak var namePurchase: UILabel!
    @IBOutlet weak var pricePurchase: UILabel!
    @IBOutlet weak var countPrivateServers: UILabel!
    
    var reloadData : (()->())? = nil
 
    override func viewDidLoad() {
        super.viewDidLoad()
        writeDateShowBaner()
        getCountPrivateServer()
        getPrice()
        
        NotificationCenter.default.addObserver(self, selector: #selector(paymentWait), name: NSNotification.Name(rawValue: IAPManager.productSKPaymentNotificationIdentifier), object: nil)
    }
    
    //MARK:- Helpers
    fileprivate func writeDateShowBaner(){
        UserDefaults.standard.set(Int64(Date().timeIntervalSince1970), forKey: UDID.bannerTryProToday.getKey)
    }
    
    fileprivate func getCountPrivateServer(){
        var countPrivateS = 0
        for server in ServerList.shared.serverList.value{
            if let s = server, let status = s.status, status.uppercased() == StatusServer.pro.getValue.uppercased(){
                countPrivateS += 1
            }
        }
        countPrivateServers.text = "\(countPrivateS) PRIVATE SERVERS"
    }
    
    fileprivate func getPrice(){
        for product in IAPManager.shared.products{
            let price = IAPManager.shared.priceStringFor(product: product)
            switch product.productIdentifier{
            case IAAProducts.sixMonth.getID:
                namePurchase.text = "\(product.localizedTitle)"
                pricePurchase.text = "try for free"
            default: break
            }
        }
    }
    
    //MARK:- Actions
    @IBAction func close(_ sender: UIButton) {
        self.removeAllOverlays()
      
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func purchase(_ sender: UIButton) {
        self.showWaitOverlay()
        IAPManager.shared.purchase(productWith: IAAProducts.sixMonth.getID)
    }
    
    @objc func paymentWait(){
        self.removeAllOverlays()
        if let reloadData = self.reloadData{
            reloadData()
        }
    }
    
    //MARK:- deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("BanerTryProViewController is deinit")
    }
}
