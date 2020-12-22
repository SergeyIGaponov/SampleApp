//
//  RatingViewController.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit
import Cosmos
import MessageUI


class RatingViewController: UIViewController {

    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var circleImage: UIImageView!
    
    var heightCircle: CGFloat = 0.0
    var isAnimateCircle = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        heightCircle = circleImage.frame.height
        
        UserDefaults.standard.set(Int64(Date().timeIntervalSince1970), forKey: UDID.showRatingToday.getKey)
        animationCircle()
        
        ratingView.didFinishTouchingCosmos = {  [weak self] val in
            if val > 0{
                UserDefaults.standard.set(false, forKey: UDID.showRating.getKey)
                if val == 4 || val == 5{
                    self?.openAppStore()
                }else{
                    self?.sendEmail()
                }
            }else{
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //MARK:- Helpers
    private func animationCircle(){
        self.circleImage.layoutIfNeeded()
        UIView.animate(withDuration: 1.0, animations: {
            [weak self] in
            if let self = self{
                if self.heightCircle == self.circleImage.frame.height{
                   self.circleImage.frame = CGRect(x: self.circleImage.frame.origin.x, y: self.circleImage.frame.origin.y, width: self.heightCircle + 10.0, height: self.heightCircle + 10.0)
                }else{
                    self.circleImage.frame = CGRect(x: self.circleImage.frame.origin.x, y: self.circleImage.frame.origin.y, width: self.heightCircle, height: self.heightCircle)
                }
            }
        }) { [weak self] (_) in
            if let self = self, self.isAnimateCircle{
                self.circleImage.layoutIfNeeded()
                self.animationCircle()
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
    
    private func openAppStore(){
        if let url = URL(string: "https://itunes.apple.com/ru/app/tap2free/id1464897458?mt=8") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Earlier versions
                if UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.openURL(url as URL)
                }
            }
        }
    }

    //MARK:- Actions
    @IBAction func notNow(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: UDID.showRating.getKey)
        dismiss(animated: true, completion: nil)
    }
    
}

extension RatingViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
