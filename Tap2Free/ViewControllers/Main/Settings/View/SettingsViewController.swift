//
//  SettingsViewController.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit
import OptimalLabelTextSize
import SideMenu

class SettingsViewController: BaseViewController {

    @IBOutlet weak var nameDefaultServer: TextSizeDevice!
    @IBOutlet weak var nearestServerSwitch: UISwitch!
    @IBOutlet weak var minNumberServerSwitch: UISwitch!
    @IBOutlet weak var startUpSwitch: UISwitch!
    @IBOutlet weak var serverContainer: UIView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var isHideLocationList = false
    var serverType: HomeViewModelServerType!
    var selectRowServer : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        animationServerContainer(isHide: !isHideLocationList, duration: 0.0)
        setValueComponents()
        
    }
    
    deinit{
        print("SettingsViewController is deinit")
    }
    
    
    //MARK:- Transitions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueID.segueSettingsLocationServer.getID {
            if let vc = segue.destination as? SettingsLocationListViewController {
                
                vc.settingsLocViewModel = SettingsLocationListViewModel(serverType: self.serverType)
                vc.isSelect = {
                    [weak self] rowValue in
                    if let self = self{
                        self.isHideLocationList = true
                        self.animationServerContainer(isHide: self.isHideLocationList, duration: 0.5)
                        
                        self.selectRowServer = rowValue
                        if rowValue < self.serverType.serverList.value.count,
                            let server = self.serverType.serverList.value[rowValue],
                            let name = server.name{
                            self.nameDefaultServer.text = name
                        }else{
                            self.nameDefaultServer.text = ""
                        }
                    }
                }
            }
        }
    }
    
    
    
    //MARK:- Helpers
    private func animationServerContainer(isHide: Bool, duration: Double){
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseIn], animations: {
            [weak self] in
            if isHide{
                self?.serverContainer.alpha = 0.0
            }else{
                self?.serverContainer.alpha = 1.0
            }
        })
        
        isHideLocationList = !isHideLocationList
    }
    
    private func setValueComponents(){
        if let startUp = UserDefaults.standard.value(forKey: UDID.settingsStartUp.getKey) as? Bool{
            startUpSwitch.isOn = startUp
        }else{
            UserDefaults.standard.set(false, forKey: UDID.settingsStartUp.getKey)
        }
        
        if let nearest = UserDefaults.standard.value(forKey: UDID.nearestServer.getKey) as? Bool{
            nearestServerSwitch.isOn = nearest
        }else{
            UserDefaults.standard.set(false, forKey: UDID.nearestServer.getKey)
        }
        
        if let minNumber = UserDefaults.standard.value(forKey: UDID.minNumberServer.getKey) as? Bool{
            minNumberServerSwitch.isOn = minNumber
        }else{
            UserDefaults.standard.set(true, forKey: UDID.minNumberServer.getKey)
        }
    }
    
    //MARK:- Actions
    @IBAction func menu(_ sender: UIBarButtonItem) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
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
    
    @IBAction func selectDefualtServer(_ sender: UIButton) {
         animationServerContainer(isHide: !isHideLocationList, duration: 0.5)
    }
    
    @IBAction func connectStartup(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UDID.settingsStartUp.getKey)
    }
    
    @IBAction func nearestSever(_ sender: UISwitch) {
        if !sender.isOn || (!minNumberServerSwitch.isOn == sender.isOn){
            UserDefaults.standard.set(sender.isOn, forKey: UDID.nearestServer.getKey)
        }else{
                minNumberServerSwitch.isOn = !minNumberServerSwitch.isOn
                UserDefaults.standard.set(sender.isOn, forKey: UDID.nearestServer.getKey)
                UserDefaults.standard.set(minNumberServerSwitch.isOn, forKey: UDID.minNumberServer.getKey)
        }
    }
    
    @IBAction func minNumberServer(_ sender: UISwitch) {
        if !sender.isOn || (!nearestServerSwitch.isOn == sender.isOn){
            UserDefaults.standard.set(sender.isOn, forKey: UDID.minNumberServer.getKey)
        }else{
            nearestServerSwitch.isOn = !nearestServerSwitch.isOn
            UserDefaults.standard.set(nearestServerSwitch.isOn, forKey: UDID.nearestServer.getKey)
            UserDefaults.standard.set(sender.isOn, forKey: UDID.minNumberServer.getKey)
        }
    }
}
