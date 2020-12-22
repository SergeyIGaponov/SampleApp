//
//  AppDelegate.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit
import Moya
import RxSwift
import GoogleMobileAds
import SideMenu


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isStartApp = true
    
    private let videoRewardsAdUnitID = "ca-app-pub-9701377/6423282553"
    
    //MARK:- Providers
//    let providerFiosServersServerAPI = MoyaProvider<FiosServersServerAPI>(manager: DefaultAlamofireManager.sharedManager)

    let providerFiosServersServerAPI = MoyaProvider<FiosServersServerAPI>(session: DefaultAlamofireManager.sharedManager)

    

    let disposeBag = DisposeBag()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setDataFirstStartApp()
        
        IAPManager.shared.checkValid()
        
        IAPManager.shared.setupPurchases { (success) in
            if success{
                print("Can make payments")
                IAPManager.shared.getProducts()
            }else{
//                let alert = UIAlertController(title: Titl, message: <#T##String?#>, preferredStyle: <#T##UIAlertController.Style#>)
            }
        }
        
        
        let proStatus = UserDefaults.standard.value(forKey: UDID.subscribtion.getKey) as? Bool ?? false
        
        if !proStatus{
            GADMobileAds.sharedInstance().start(completionHandler: nil)
         
            GADRewardBasedVideoAd.sharedInstance().delegate = self
            GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                        withAdUnitID: "ca-app-pub-9942544/1712485313")
    //        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
    //                                                    withAdUnitID: videoRewardsAdUnitID)
        }
        return true
    }
    
    func setDataFirstStartApp(){
        guard (UserDefaults.standard.value(forKey: UDID.firstDateStartApp.getKey) as? Int64) != nil else{
            UserDefaults.standard.set(Int64(Date().timeIntervalSince1970), forKey: UDID.firstDateStartApp.getKey)
            return
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: GADRewardBasedVideoAdDelegate {
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
//        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue: NotificationKey.rewardBasedVideoAdDidReceive.getName), object: nil)
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: "ca-app-pub-99942544/1712485313")
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
//        print("Reward based video ad has completed.")
         NotificationCenter.default.post(name:  NSNotification.Name(rawValue: NotificationKey.rewardBasedVideoAdDidReceive.getName), object: nil)
    }
}

