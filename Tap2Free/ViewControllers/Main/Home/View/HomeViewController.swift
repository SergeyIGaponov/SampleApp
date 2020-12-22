//
//  HomeViewController.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit
import SideMenu
import SDWebImage
import NetworkExtension
import SwiftOverlays
import OptimalLabelTextSize
import Alamofire
import PlainPing
import GoogleMobileAds
import RxSwift
import RxCocoa

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var locationList: UIView!
    @IBOutlet weak var arrowLocation: UIImageView!
    @IBOutlet weak var locationListHeight: NSLayoutConstraint!
    
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var flagImage: UIImageView!
    
    @IBOutlet weak var mapsImage: UIImageView!
    @IBOutlet weak var connectBtn: DesignableUIButton!
    @IBOutlet weak var connectShadow: DesignableView!
    @IBOutlet weak var statusConnect: UILabel!
    @IBOutlet weak var titleIP: UILabel!
    @IBOutlet weak var statusConnection: UIImageView!
    @IBOutlet weak var pingSignal: UIImageView!
    
    @IBOutlet weak var checkIpBtn: DesignableUIButton!
    @IBOutlet weak var getProView: UIView!
    @IBOutlet weak var shadowGetProView: UIView!
    @IBOutlet weak var getPro_Btn: UIButton!
    
    @IBOutlet weak var baner: UIView!
    @IBOutlet weak var underVIew: UIView!
    
    
    var isHideLocationList = false
    var rowSelectLocation = 0
    
    //Google Ads
    var bannerView: GADBannerView?
    let bannerMapAdUnitID = "ca-app-pub-2765862849701377/7702427409"
    let fullScreenBannerAdUnitID = "ca-app-pub-2765862849701377/1975813223"
    var interstitial: GADInterstitial?
    var isFullScreeBanner = false
    

    let delegate = UIApplication.shared.delegate as! AppDelegate
    var providerManager : NETunnelProviderManager?
    let bundleIDExtension = "com.msofter.altcoinapps.Tap2Free.Tap2FreeNetworkExtension"
    var statusVPN = NEVPNStatus.invalid

    let daysShowRaiting = 3
    
    var minPing = Double.greatestFiniteMagnitude
    
    var gestureCloseServerList : UITapGestureRecognizer!
    
    
    private var homeViewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingDropDownList()
    
        setupSideMenu()
        setupOptimalFont()
        
        if !self.homeViewModel.statusSubscribe(){
            setupGoogleAds()
            shadowGetProView.isHidden = false
        }else{
            shadowGetProView.isHidden = true
        }
        
        animationDropDown(isHide: !isHideLocationList, duration: 0.0)
        
        setNotification()
        
        if providerManager == nil{
            reloadCurrentManager(startVPN: false)
        }
        
        subscribes()
    }
    
    
    private func subscribes(){
       //MARK:- DataSettings
       //запрос на получение настроек с сервера выполнятся при создании HomeViewModel
       //выполнится первым
       //в любом случае по завершению отработает подписка
        homeViewModel.dataSettings.asObservable().skip(1).subscribe(onNext: { [weak self] (dataSettings) in
            //Запрашиваем список доступных серверов
            ServerList.shared.requestListServers(url: .url)
            if let self = self{
                self.saveVersionApp()
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
           
        //MARK:- ServerList
        //запрос на получение списка серверов выполнятся при отработки запроса получения dataSettings
        homeViewModel.serverList.asObservable().skip(1).subscribe(onNext: { [weak self] (serverList) in
            if let self = self{
                //устанавливаем максимальную и минимальную
                self.setHeightListServer()
                
                if self.homeViewModel.clickRadar == false{
                    
                    //реклама при подключении
                    //параметр isFullScreenBaner может изменить на true если нет подписки и есть необходимость показать рекламу
                    self.checkSettingFullScreenBanner()
                    
                    //банер предлагающий оформить подписку
                    self.checkSettingBanner()
                    
                    //Получить конфигурацию сервера
                    self.homeViewModel.getIpConnect()
                }else{
                    self.homeViewModel.getIPWithMinPing()
                    self.homeViewModel.clickRadar = false
                }
                //как только будет найден ip сервера сработает подписка .locationServerViewModelType.selectedIp
                //которая позволит загрузить конфигурацию для OpenVPN
            }
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
       
        
        //MARK:- Config были получены
        homeViewModel.config.asObservable().subscribe(onNext: { [weak self] (config) in
            if config != nil, let self = self, self.homeViewModel.isStartConnectVPN(), self.homeViewModel.needConnectType{
                self.connect()
                self.homeViewModel.connect(ifNeed: false)
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        
        //MARK:- ip был изменен
        //Показываем актуальный сервер из списка
        //При изменении загружаем конфигурацию
        //Отменям переключение сервера при активного подключении VPN
        homeViewModel.locationServerDelegate.locationServerViewModelType.selectedIp.asObservable().subscribe(onNext: { [weak self] (ip) in
             //Показать сервер из списка
            let server = self?.homeViewModel.getServer(on: ip)
            if let self = self, let index = self.homeViewModel.getIndexServer(on: server), let selectedServer = self.homeViewModel.serverList.value[index]{
                let statusIP = self.homeViewModel.locationServerDelegate.locationServerViewModelType.getStatusSubscribe(on: IndexPath(row: index, section: 0))
                
                let statusSubscribe = self.homeViewModel.statusSubscribe()
                switch statusIP {
                case .pro:
                    if statusSubscribe{
                        if self.checkStatusVPN(selectIP: ip){
                            self.updateViewSelectedServer(server: selectedServer)
                            self.titleIP.text = ip
                            self.homeViewModel.oldIpConnect = ip
                            ConfigData.shared.requestConfig(from: ip, url: .url)
                        }else{
                            self.homeViewModel.locationServerDelegate.locationServerViewModelType.selectedIp.accept(self.homeViewModel.oldIpConnect)
                        }
                    }else{
                        self.homeViewModel.locationServerDelegate.locationServerViewModelType.selectedIp.accept(self.homeViewModel.getAnyIpFree() ?? "")
                        //открываем экран покупок
                        if let vc = SideMenuManager.default.menuLeftNavigationController{
                            let vcMenu = vc.topViewController as! SideMenuViewController
                            vcMenu.selectItem = .removeAd
                            vcMenu.changeSelectItem()
                            self.performSegue(withIdentifier: SegueID.segueRemoveAdNav.getID, sender: nil)
                        }
                    }
                default:
                    if self.checkStatusVPN(selectIP: ip){
                        self.updateViewSelectedServer(server: selectedServer)
                        self.titleIP.text = ip
                        self.homeViewModel.oldIpConnect = ip
                        ConfigData.shared.requestConfig(from: ip, url: .url)
                    }else{                        self.homeViewModel.locationServerDelegate.locationServerViewModelType.selectedIp.accept(self.homeViewModel.oldIpConnect)
                    }
                }
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        //показать ромашку если происходит запрос
        OverlaysVariable.shared.overlay.asObservable().subscribe(onNext: { [weak self] (overlay) in
            if overlay == .hide{
                self?.removeAllOverlays()
            }else{
                self?.showWaitOverlay()
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        //показать ошибку во время запросов
        ErrorRequests.errorRequestApi.asObservable().subscribe(onNext: { [weak self] (error) in
            if let error = error{
                self?.showAlert(with: error.errorLocalazible)
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
    }
    
    
    //true меням сервер
    private func checkStatusVPN(selectIP: String) -> Bool {
        isHideLocationList = true
        animationDropDown(isHide: isHideLocationList, duration: 0.0)
        if (self.statusVPN != .connected &&
            self.statusVPN != .connecting) ||
            (selectIP == self.homeViewModel.oldIpConnect){
            return true
        }else{
            guard let alert = self.showMessage(msg: "Disable the current VPN", tittle: TitlesAlerts.error.getValue, actionBtn: TitleAlertButton.ok.getValue, callback: {})
                else { return false }
            
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    //MARK:- Helpers
    private func settingDropDownList(){
        //отслеживаем нажатие на область вне выпадающего списка
        //активна если список открыт
        underVIew.isHidden = true
        gestureCloseServerList = UITapGestureRecognizer(target: self, action: #selector(tapCloseGesture))
        gestureCloseServerList.isEnabled = false
        underVIew.addGestureRecognizer(gestureCloseServerList)
    }
    
    private func showAlert(with text: String){
        if let alert = self.showMessage(msg: text,
                                        tittle: TitlesAlerts.error.getValue,
                                        actionBtn: TitleAlertButton.ok.getValue,
                                        callback: {
                                        ErrorRequests.setError(error: nil)
        }){
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func updateViewSelectedServer(server: Server){
        if let name = server.name{
            serverName.text = name
        }
        
        if let urlImageMap = server.map_url{
            mapsImage.sd_setImage(with: URL(string: urlImageMap), placeholderImage: UIImage(named: ""), options: SDWebImageOptions(rawValue: 0), completed: nil)
        }else{
            mapsImage.image = nil
        }
        
        if let urlImageFlag = server.flag_url{
            flagImage.sd_setImage(with: URL(string: urlImageFlag), placeholderImage: UIImage(named: ""), options: SDWebImageOptions(rawValue: 0), completed: nil)
        }else{
            flagImage.image = nil
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("HomeViewController is deinit")
    }
    
    
    //MARK:- Helpers
    private func setNotification(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(rewardBasedVideoAdDidReceive), name: NSNotification.Name(rawValue: NotificationKey.rewardBasedVideoAdDidReceive.getName), object: nil)
        
        
        //изменение статуса подписки
        NotificationCenter.default.addObserver(self, selector: #selector(paymentWait), name: NSNotification.Name(rawValue: IAPManager.productSKPaymentNotificationIdentifier), object: nil)
        
    }
    
    @objc func rewardBasedVideoAdDidReceive(){
        UserDefaults.standard.set(getCurrentDate(), forKey: UDID.timeConnect.getKey)
    }
    
    //MARK:- Status subscribe
    @objc func paymentWait(){
        if self.homeViewModel.statusSubscribe(){
            //удаляем банер (на карте)
            bannerView?.removeFromSuperview()
        }
    }
    
    private func checkSettingFullScreenBanner(){
        if homeViewModel.statusSubscribe() == false{
            //проверяем нужно ли показывать рекламу
            if let dSettings = homeViewModel.dataSettings.value, let connect_ads = dSettings.connect_ads, let connect_ads_day = dSettings.connect_ads_day{
                if let value = UserDefaults.standard.value(forKey: UDID.firstDateStartApp.getKey) as? Int64{
                    let seconds = connect_ads_day * 24 * 3600 // день на который нужно показывать рекламу после клика на подключиться
                    if Int64(Date().timeIntervalSince1970) - value + 86400 >= seconds{
                        if connect_ads == 1 {
                            isFullScreeBanner = true
                        }
                    }
                }
            }
        }else{
            isFullScreeBanner = false
        }
    }
    
    private func checkSettingBanner(){
        if homeViewModel.statusSubscribe() == false{
            if let dSettings = self.homeViewModel.dataSettings.value,
                let strDay_try_pro = dSettings.day_try_pro,
                let day_try_pro = Int(strDay_try_pro),
                let try_pro_always_on_startup = dSettings.try_pro_always_on_startup{
                if let value = UserDefaults.standard.value(forKey: UDID.firstDateStartApp.getKey) as? Int64{
                    let seconds = day_try_pro * 24 * 3600 // день на который нужно показывать банер
                    if Int64(Date().timeIntervalSince1970) - value + 86400 >= seconds{
                        if try_pro_always_on_startup == 1{
                            //показать банер tryPro
                            performSegue(withIdentifier: SegueID.segueBanerTryPro.getID, sender: self)
                        }else{
                            if let tadayBanner = UserDefaults.standard.value(forKey: UDID.bannerTryProToday.getKey) as? Int64{
                                if Int64(Date().timeIntervalSince1970) - tadayBanner >= 86400{
                                    //показываем банер tryPro
                                    performSegue(withIdentifier: SegueID.segueBanerTryPro.getID, sender: self)
                                }else{
                                    return
                                }
                            }else{
                                performSegue(withIdentifier: SegueID.segueBanerTryPro.getID, sender: self)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func setHeightListServer(){
        if self.homeViewModel.serverList.value.count < 6{
            self.locationListHeight.constant = CGFloat(50 * self.homeViewModel.serverList.value.count)
        }else{
            self.locationListHeight.constant = CGFloat(300)
        }
        self.locationList.layoutIfNeeded()
    }
    
    //MARK:- SideMenu
    private func setupSideMenu() {
        // Define the menus
        let storyboard = UIStoryboard(name: StoryboardName.Main.getName, bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: ControllerID.leftMenuNavigationController.getID) as? UISideMenuNavigationController
                else { return }
                
        SideMenuManager.default.menuLeftNavigationController = vc
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: nil)
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuBlurEffectStyle = .none
        
        let vcMenu = vc.topViewController as! SideMenuViewController
        vcMenu.menuItemSelect = {
            [weak self] menuItem in
            if let segue = menuItem.segueId{
                DispatchQueue.main.async {
                    self?.navigationController?.popToRootViewController(animated: false)
                    self?.performSegue(withIdentifier: segue.getID, sender: nil)
                }
            }else{
                if menuItem == .support{
                    self?.showRatingController()
                }else{
                    //connection
                    self?.navigationController?.popToRootViewController(animated: false)
                }
            }
        }
    }
    
    private func changeButtonConnection(isConnect: Bool){
        if isConnect{
            connectBtn.setTitle(TitleUI.connect.getTitle, for: .normal)
            connectBtn.setImage(#imageLiteral(resourceName: "connect"), for: .normal)
            connectBtn.backgroundColor = #colorLiteral(red: 0.5894152522, green: 0.7814149261, blue: 0.3432275653, alpha: 1)
            connectShadow.backgroundColor = #colorLiteral(red: 0.5894152522, green: 0.7814149261, blue: 0.3432275653, alpha: 1)
            connectShadow.shadowColor = #colorLiteral(red: 0.5894152522, green: 0.7814149261, blue: 0.3432275653, alpha: 1)
        }else{
            connectBtn.setTitle(TitleUI.disconnect.getTitle, for: .normal)
            connectBtn.setImage(#imageLiteral(resourceName: "disconnect"), for: .normal)
            connectBtn.backgroundColor = #colorLiteral(red: 1, green: 0.3152123094, blue: 0.2753253281, alpha: 1)
            connectShadow.backgroundColor = #colorLiteral(red: 1, green: 0.3152123094, blue: 0.2753253281, alpha: 1)
            connectShadow.shadowColor = #colorLiteral(red: 1, green: 0.3152123094, blue: 0.2753253281, alpha: 1)
        }
    }
  
    func getCurrentDate()->Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
    
    //Оптимизируем шрифты для кнопок
    private func setupOptimalFont(){
        let k = DeviceDiagonal.getDiagonal().inch / DeviceSize.XR_6_1.inch
        TextSizeDevice.setTextSize(with: k, currentSize: 19.0, strengthenK: 1.0, maxTextSize: 19, minTextSize: 14, label: connectBtn.titleLabel!)
        TextSizeDevice.setTextSize(with: k, currentSize: 14.0, strengthenK: 1.0, maxTextSize: 14, minTextSize: 9, label: checkIpBtn.titleLabel!)
    }
   
    private func saveVersionApp(){
        if let dataSettings = self.homeViewModel.dataSettings.value, let min_version = dataSettings.min_version{
            var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            appVersion = String(appVersion.prefix(min_version.count))
            if appVersion.uppercased() != min_version.uppercased(){
                openAppStore()
            }
        }
    }
    
    private func openAppStore(){
        alertUpdateApp()
    }
    
    private func alertUpdateApp(){
        let alert = UIAlertController(title: TitlesAlerts.warning.getValue, message: TitlesAlerts.textWarning.getValue, preferredStyle: .alert)
      
        let updateAction = UIAlertAction(title: TitleAlertButton.update.getValue, style: .default) { (_) in
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
        let cancelAction = UIAlertAction(title: TitleAlertButton.cancel.getValue, style: .cancel, handler: nil)
        
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- Animation Hide or Show
    private func animationDropDown(isHide: Bool, duration: Double){
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseIn], animations: {
            [weak self] in
            if isHide{
                self?.underVIew.isHidden = true
                self?.gestureCloseServerList.isEnabled = false
                self?.locationList.alpha = 0.0
                self?.arrowLocation.transform = CGAffineTransform(rotationAngle: (CGFloat(Double.pi)) / 360.0)
            }else{
                self?.underVIew.isHidden = false
                self?.gestureCloseServerList.isEnabled = true
                self?.locationList.alpha = 1.0
                self?.arrowLocation.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            }
        })
        
        isHideLocationList = !isHideLocationList
    }
    
    fileprivate func showRatingView(){
        let showRating = UserDefaults.standard.value(forKey: UDID.showRating.getKey) as? Bool ?? true
        print(showRating)
        if showRating{
            if let value = UserDefaults.standard.value(forKey: UDID.firstDateStartApp.getKey) as? Int64{
                let seconds = daysShowRaiting * 24 * 3600 // день на который нужно показывать рекламу после клика на подлючиться
                if Int64(Date().timeIntervalSince1970) - value + 86400 >= seconds{
                    if let today = UserDefaults.standard.value(forKey: UDID.showRatingToday.getKey) as? Int64{
                        print("ToDay", Int64(Date().timeIntervalSince1970) - today)
                        if Int64(Date().timeIntervalSince1970) - today >= 86400{
                            showRatingController()
                        }
                    }else{
                        showRatingController()
                    }
                }
            }
        }
    }
    
    //MARK:- Google Ads
    fileprivate func setupGoogleAds(){
        interstitial = createAndLoadInterstitial()
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
        
        addBannerViewToView(bannerView!)
        
        bannerView!.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        bannerView.adUnitID = bannerMapAdUnitID
        bannerView!.rootViewController = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.bannerView!.load(GADRequest())
        }
        
        bannerView!.delegate = self
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        baner.addSubview(bannerView)
        baner.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: baner,
                               attribute: .centerY,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: bannerView,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: baner,
                               attribute: .centerX,
                               multiplier: 1,
                               constant: 0)]
        )
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
//        let interstitial = GADInterstitial(adUnitID: fullScreenBannerAdUnitID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
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
    
    @IBAction func location(_ sender: UIButton) {
        animationDropDown(isHide: !isHideLocationList, duration: 0.5)
    }
    
    @IBAction func getPro(_ sender: UIButton) {
        if let vc = SideMenuManager.default.menuLeftNavigationController{
            let vcMenu = vc.topViewController as! SideMenuViewController
            vcMenu.selectItem = .removeAd
            vcMenu.changeSelectItem()
        }
        performSegue(withIdentifier: SegueID.segueRemoveAdNav.getID, sender: nil)
    }
    
    @IBAction func connection(_ sender: DesignableUIButton) {
        switch (self.statusVPN) {
        case .invalid, .disconnected:
            if let interstitial = interstitial, interstitial.isReady {
                //проверяем настройки и подписку
                self.checkSettingFullScreenBanner()
                if isFullScreeBanner{
                    interstitial.present(fromRootViewController: self)
                }else{
                    self.connect()
                }
            } else {
                self.connect()
            }
        case .connected, .connecting:
            self.disconnect()
        default:
            break
        }
    }
   
   //MARK:- Radar
    @IBAction func radar(_ sender: UIButton) {
        if statusVPN != .connected && statusVPN != .connecting{
            self.homeViewModel.clickRadar = true
            OverlaysVariable.shared.changeOverlays(on: .show)
            ServerList.shared.pingNext(serverList: homeViewModel.serverList.value, index: 0) { [weak self] (serverList) in
                OverlaysVariable.shared.changeOverlays(on: .hide)
                self?.homeViewModel.serverList.accept(serverList)
            }
        }else{
            guard let alert = self.showMessage(msg: "Disable the current VPN", tittle: TitlesAlerts.error.getValue, actionBtn: TitleAlertButton.ok.getValue, callback: {}) else { return }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func checkIP(_ sender: UIButton) {
        if let url = URL(string: "http://myip.tap2free.net") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    //MARK:- Gesture
    @objc func tapCloseGesture(){
        animationDropDown(isHide: true, duration: 0.5)
    }

    //MARK:- Transitions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueID.segueBanerTryPro.getID{
            if let vc = segue.destination as? BanerTryProViewController{
                vc.reloadData = {
                    [weak self] in
                    //убрать рекламу
                }
            }
        }
        
        if let identifier = segue.identifier, identifier == SegueID.segueLocationServer.getID{
            if let dvc = segue.destination as? LocationServerViewController{
                self.homeViewModel.locationServerDelegate = dvc as LocationServerDelegate
            }
            return
        }
        
        if let identifier = segue.identifier, identifier == SegueID.segueServerList.getID{
            if let dvc = segue.destination as? ServersListViewController{
                dvc.locationServerViewModel = self.homeViewModel.locationServerDelegate.locationServerViewModelType
            }
            return
        }
        
        if let identifier = segue.identifier, identifier == SegueID.segueSettings.getID{
            if let dvc = segue.destination as? SettingsViewController{
                dvc.serverType = self.homeViewModel
            }
        }
        
        if let identifier = segue.identifier, identifier == SegueID.segueRemoveAdNav.getID{
            if let dvc = segue.destination as? ADViewController{
            }
        }
    }
}

//MARK:- VPN Connection
extension HomeViewController{
    
    func reloadCurrentManager(startVPN: Bool){
        
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            guard error == nil else {
                return
            }
            
            var manager: NETunnelProviderManager!
            
            for m in managers! {
                if let p = m.protocolConfiguration as? NETunnelProviderProtocol {
                    if (p.providerBundleIdentifier == self?.bundleIDExtension) {
                        manager = m
                        break
                    }
                }
            }
            
            if (manager == nil) {
                manager = NETunnelProviderManager()
            }
            
            self?.providerManager = manager
            self?.statusVPN = manager.connection.status
            if manager.connection.status == .connected || manager.connection.status == .connecting{
                self?.homeViewModel.getIpOldConnect()
            }
            
            self?.configVPN(startVPN: startVPN)
        }
    }
    
    func configVPN(startVPN: Bool){
        self.providerManager?.loadFromPreferences(completionHandler: { [weak self] (error) in
            guard error == nil else {
                // Handle an occurred error
                return
            }

            self?.setupViewFromStatus()

        
            if (startVPN){
                guard let s = self, let configProto = s.homeViewModel.config.value, let serverAddress = configProto.ip, let config = configProto.config else {
                    return
                }

                // Assuming the app bundle contains a configuration file named 'client.ovpn' lets get its
                // Data representation

                let tunnelProtocol = NETunnelProviderProtocol()

                tunnelProtocol.serverAddress = serverAddress

                // The most important field which MUST be the bundle ID of our custom network
                // extension target.
                tunnelProtocol.providerBundleIdentifier = self?.bundleIDExtension


                guard let configurationFileContent = config.data(using: .utf8) else{
                    return
                }

                // Use `providerConfiguration` to save content of the ovpn file.
                tunnelProtocol.providerConfiguration = ["ovpn": configurationFileContent]

                tunnelProtocol.username = "username"
                tunnelProtocol.passwordReference =  Data(base64Encoded: "vpn")

                // Finish configuration by assigning tunnel protocol to `protocolConfiguration`
                // property of `providerManager` and by setting description.
                self?.providerManager?.protocolConfiguration = tunnelProtocol
                self?.providerManager?.localizedDescription = "Tap2Free"

                self?.providerManager?.isEnabled = true

                // Save configuration in the Network Extension preferences
                self?.providerManager?.saveToPreferences(completionHandler: { (error) in
                    if error != nil  {
                        // Handle an occurred error
                    }else{
                        try? self?.providerManager?.connection.startVPNTunnel()
                        if let mConfig = self?.homeViewModel.config.value, let ip = mConfig.ip{
                            UserDefaults.standard.set(ip, forKey: UDID.connectIP.getKey)
                        }
                    }
                })

            }
        })
    }
    
    func setupViewFromStatus(){
        self.statusVPN = providerManager?.connection.status ?? NEVPNStatus.disconnected

        switch self.statusVPN {
        case .connected:
            statusConnect.text = "Connected"
            changeButtonConnection(isConnect: false)
            titleIP.text = getIPCoonection()
            statusConnection.image = #imageLiteral(resourceName: "status-connect")
            showRatingView()
        case .connecting:
            statusConnect.text = "Connecting"
            changeButtonConnection(isConnect: false)
            titleIP.text = getIPCoonection()
            statusConnection.image = #imageLiteral(resourceName: "status-disconnect")
    
        case .disconnecting:
            statusConnect.text = "Disconnecting"
            changeButtonConnection(isConnect: true)
            statusConnection.image = #imageLiteral(resourceName: "status-disconnect")
            
        default:
            statusConnect.text = "Disconnected"
            changeButtonConnection(isConnect: true)
            statusConnection.image = #imageLiteral(resourceName: "status-disconnect")

        }
    }
    
    
    @objc private func VPNStatusDidChange(notification: NSNotification) {
        setupViewFromStatus()
    }
    
    func connect(){
        if providerManager == nil{
            reloadCurrentManager(startVPN: true)
        }else{
            configVPN(startVPN: true)
        }
    }
    
    func disconnect(){
        if providerManager == nil{
            reloadCurrentManager(startVPN: false)
            providerManager?.connection.stopVPNTunnel()
        }else{
            providerManager?.connection.stopVPNTunnel()
        }
    }
    
    func getIPCoonection()-> String{
        if let mConfig = homeViewModel.config.value, let ip = mConfig.ip{
            return ip
        }
        return ""
    }
}

//GoogleAds
extension HomeViewController: GADBannerViewDelegate{
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
        
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}

extension HomeViewController: GADInterstitialDelegate{
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        
        interstitial = createAndLoadInterstitial()
        self.connect()

    }
}
