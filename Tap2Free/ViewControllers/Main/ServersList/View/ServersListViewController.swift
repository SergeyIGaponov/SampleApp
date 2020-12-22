//
//  ServersListViewController.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit
import SideMenu
import SDWebImage
import NetworkExtension
import RxSwift
import RxCocoa

class ServersListViewController: BaseViewController {
   
    @IBOutlet weak var namePurchase: UILabel!
    @IBOutlet weak var pricePurchase: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var locationServerViewModel: LocationServerViewModelType!
    var openRemoveAd: (()->())? = nil
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(paymentWait), name: NSNotification.Name(rawValue: IAPManager.productSKPaymentNotificationIdentifier), object: nil)
    }
    
    
    
    //MARK:- Helpers
    fileprivate func getPrice(){
        for product in IAPManager.shared.products{
            let price = IAPManager.shared.priceStringFor(product: product)
            switch product.productIdentifier{
            case IAAProducts.sixMonth.getID:
                namePurchase.text = "\(product.localizedTitle)"
                let number = (Double(truncating: price.1) / 6.0).rounded()
                let currency = (String(price.0.components(separatedBy: CharacterSet.symbols.inverted).joined()))
                pricePurchase.text = "for only \(number) \(currency) / month"
            default: break
            }
        }
    }
    
    private func subscribe(){
        locationServerViewModel.selectedIp.asObservable().subscribe(onNext: { (_) in
                self.tableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
              
        
        ServerList.shared.serverList.asObservable().subscribe(onNext: { [weak self] (listServer) in
            if listServer.count > 0{
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    
    //MARK:- Actions
    @IBAction func menu(_ sender: UIBarButtonItem) {
        guard let leftMenuNavigationController = SideMenuManager.default.menuLeftNavigationController else {
            return
        }
        present(leftMenuNavigationController, animated: true, completion: nil)
    }
    

    @IBAction func payment(_ sender: UIButton) {
        self.showWaitOverlay()
        IAPManager.shared.purchase(productWith: IAAProducts.sixMonth.getID)
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        let text = URLsApp.share.getUrl
        
        // set up activity view controller
        let textToShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func paymentWait(){
        self.removeAllOverlays()
    }
    
    //MARK:- deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("ServersListViewController is deinit")
    }
    
}

extension ServersListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationServerViewModel.numberOfRowsInSection()
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID.locationServerTableViewCell.getId) as! LocationServerTableViewCell
        cell.dataCell = locationServerViewModel.cellForRowAt(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = SideMenuManager.default.menuLeftNavigationController{
            let vcMenu = vc.topViewController as! SideMenuViewController
            vcMenu.selectItem = .connection
            vcMenu.changeSelectItem()
        }
        self.navigationController?.popToRootViewController(animated: true)
        self.locationServerViewModel.didSelectRowAt(indexPath: indexPath)
    }
}

extension ServersListViewController: LocationServerDelegate{
    var locationServerViewModelType: LocationServerViewModelType {
        return locationServerViewModel
    }
}

