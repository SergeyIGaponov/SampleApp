//
//  ADViewController.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit
import NetworkExtension
import SideMenu

class ADViewController: BaseViewController {
  
    @IBOutlet weak var countPrivateServer: UILabel!
    @IBOutlet weak var sevenDaysFree: UILabel!
    @IBOutlet weak var oneYearPro_Label: UILabel!
    @IBOutlet weak var oneMonthPro_Label: UILabel!
    @IBOutlet weak var sevenDaysPrice: UILabel!
    @IBOutlet weak var oneYearPrice: UILabel!
    @IBOutlet weak var oneMonthPrice: UILabel!

    override func viewDidLoad(){
        super.viewDidLoad()
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        getCountPrivateServer()
        getPrice()
        
        NotificationCenter.default.addObserver(self, selector: #selector(paymentWait), name: NSNotification.Name(rawValue: IAPManager.productSKPaymentNotificationIdentifier), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeAllOverlays()
    }
    
    
    //MARK:- Helpers
    fileprivate func getCountPrivateServer(){
        var countPrivateS = 0
        for server in ServerList.shared.serverList.value{
            if let s = server, let status = s.status, status.uppercased() == StatusServer.pro.getValue.uppercased(){
                countPrivateS += 1
            }
        }
        countPrivateServer.text = "\(countPrivateS) PRIVATE SERVERS"
    }
    
    
    fileprivate func getPrice(){
        for product in IAPManager.shared.products{
            let price = IAPManager.shared.priceStringFor(product: product)
            switch product.productIdentifier{
            case IAAProducts.oneMonth.getID:
                oneMonthPro_Label.text = "\(product.localizedTitle)"
                oneMonthPrice.text = "for only \(price.0) / month"
            case IAAProducts.oneYear.getID:
                oneYearPro_Label.text = "\(product.localizedTitle)"
                let number = (Double(truncating: price.1) / 12.0).rounded()
                let currency = (String(price.0.components(separatedBy: CharacterSet.symbols.inverted).joined()))
                oneYearPrice.text = "for only \(number) \(currency) / month"
            case IAAProducts.sixMonth.getID:
                sevenDaysFree.text = "\(product.localizedTitle)T"
                sevenDaysPrice.text = "try for free"
            default: break
            }
        }
    }
    
    
    @objc func paymentWait(){
        self.removeAllOverlays()
    }
    
    //MARK:- Actions
    @IBAction func menu(_ sender: UIBarButtonItem) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        self.showWaitOverlay()
        IAPManager.shared.restoredCompletedTransactions()
    }
    
    @IBAction func oneMonthPro(_ sender: UIButton) {
        self.showWaitOverlay()
        IAPManager.shared.purchase(productWith: IAAProducts.oneMonth.getID)
    }
    
    @IBAction func oneYearPro(_ sender: UIButton) {
        self.showWaitOverlay()
        IAPManager.shared.purchase(productWith: IAAProducts.oneYear.getID)
    }
    
    @IBAction func sevenDaysPro(_ sender: UIButton) {
        self.showWaitOverlay()
        IAPManager.shared.purchase(productWith: IAAProducts.sixMonth.getID)
    }
    
    //MARK:- deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("ADViewController is deinit")
    }

}
