//
//  SideMenuViewController.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit
import NetworkExtension
import MessageUI

class SideMenuViewController: UIViewController {
    
    @IBOutlet var fieldBtn: [UIButton]!
    @IBOutlet weak var minVersion: UILabel!
    
    
    var selectItem = MenuItems.connection
    var menuItemSelect: ((MenuItems)->())? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        changeSelectItem()
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        minVersion.text = "Tap2Free ver. \(appVersion)"
    }
    
    //MARK:- Helpers
    
    public func changeSelectItem(){
        for item in fieldBtn{
            if item.tag == selectItem.tag{
                item.backgroundColor = #colorLiteral(red: 0.3663484156, green: 0.784211576, blue: 1, alpha: 1)
                item.alpha = 0.22
            }else{
                item.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                item.alpha = 1
            }
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["altcoinapps@gmail.com"])
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            mail.setSubject("Tap2free feedback. Version \(appVersion)")
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    //MARK:- Actions
    @IBAction func menuItem(_ sender: UIButton) {
        guard let menuItemSelect = menuItemSelect else {
            return
        }
        
        var menuItem = MenuItems.connection
        for item in MenuItems.allCases{
            if item.tag == sender.tag{
                menuItem = item
                break;
            }
        }
        
        switch menuItem {
        case .feedback:
            self.sendEmail()
        case .support:
            //открываем выбранный экран
            dismiss(animated: true) {
                menuItemSelect(menuItem)
            }
        default:
            self.selectItem = menuItem
            self.changeSelectItem()
            //открываем выбранный экран
            dismiss(animated: true) {
                menuItemSelect(menuItem)
            }
        }
    }
    
    deinit {
        print("Side menu is deinit")
    }
}

extension SideMenuViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
