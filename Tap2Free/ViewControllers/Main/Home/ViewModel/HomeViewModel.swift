//
//  HomeViewModel.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import RxSwift
import RxCocoa
import UIKit

class HomeViewModel: HomeViewModelType, HomeViewModelServerType{
    
    var serverList: BehaviorRelay<[Server?]>{
        return ServerList.shared.serverList
    }
    
    var config: BehaviorRelay<Config?>{
        return ConfigData.shared.config
    }
    
    var dataSettings: BehaviorRelay<DataSettings?>{
        return DataSettingsApp.shared.dataSettings
    }
    
    weak var locationServerDelegate: LocationServerDelegate!
    
    var needConnectType: Bool{
        return needConnet
    }
    
    //public
    private var startIpConnect = ""
    var ipForConnect = ""
    var oldIpConnect: String = ""
    
    //private
    private let delegate = UIApplication.shared.delegate as! AppDelegate
    private var isGetIpOldConnect = false //Можно получить только один раз при запуске
    
    var needConnet = true
    var clickRadar = false
    
    init() {
        
    }
    
    //MARK:- Helpers
    func connect(ifNeed: Bool){
        self.needConnet = ifNeed
    }
    
    func getIpOldConnect(){
        if isGetIpOldConnect == false, let value = UserDefaults.standard.value(forKey: UDID.connectIP.getKey) as? String{
            startIpConnect = value
            isGetIpOldConnect = true
        }else{
            startIpConnect = ""
            isGetIpOldConnect = true
        }
    }
    
    func getIpConnect(){
        if startIpConnect == ""{
            //получаем данные из настроек
            if statusSubscribe() {
                //pro
                if isNearestServer() == false && isWithMinNumber() == false{
                    //получаем сервер выбранный по умолчанию
                    if let ip = defaultIpServer(){
                        //если сервер был установлен ранее получаем его ip
                        ipForConnect = ip
                    }else{
                        //получаем ip for pro из настроек полученых с сервера
                        ipForConnect = getIpServerFromDataSettings(for: .pro)
                    }
                }else{
                    if isNearestServer() == true{
                        //устанавливаем ip по ping
                        if let minPingPro = MinPings.shared.minPingPro{
                            ipForConnect = minPingPro.ip
                        }else{
                            ipForConnect = getAnyIpPro() ?? ""
                        }
                    }
                    else{
                        if isWithMinNumber() == true{
                            //получаем ip for pro из настроек полученых с сервера
                            ipForConnect = getIpServerFromDataSettings(for: .pro)
                        }
                    }
                }
            }else{
                //free
                if isNearestServer() == false && isWithMinNumber() == false{
                    //получаем сервер выбранный по умолчанию
                    if let ip = defaultIpServer(){
                        //если сервер был установлен ранее получаем его ip
                      
                        //если полученный ip является free
                        if let server = getServer(on: ip), let status = server.status,
                            status.uppercased() == StatusServer.free.getValue.uppercased(){
                            ipForConnect = ip
                        }else{
                            //получаем ip free из настроек полученых с сервера
                            ipForConnect = getIpServerFromDataSettings(for: .free)
                        }
                    }else{
                        //получаем ip free из настроек полученых с сервера
                        ipForConnect = getIpServerFromDataSettings(for: .free)
                    }
                }else{
                    if isNearestServer() == true{
                        //устанавливаем ip по ping
                        if let minPingFree = MinPings.shared.minPingFree{
                            ipForConnect = minPingFree.ip
                        }else{
                            ipForConnect = getAnyIpFree() ?? ""
                        }
                    }else{
                        if isWithMinNumber() == true{
                            //получаем ip for pro из настроек полученых с сервера
                            ipForConnect = getIpServerFromDataSettings(for: .free)
                        }
                    }
                }
            }
        }else{
            //необходимо получить конфиг активного vpn соединения
            ipForConnect = startIpConnect
            startIpConnect = ""
        }
        
        oldIpConnect = ipForConnect
        self.locationServerDelegate.locationServerViewModelType.selectedIp.accept(ipForConnect)
    }
    
    func getIpServerFromDataSettings(for status: StatusServer) -> String{
        if status == .pro{
            if let ip = self.dataSettings.value?.start_server_pro{
                return ip
            }else{
                //найдем любой pro server
                return getAnyIpPro() ?? ""
            }
        }else{
            if let ip = self.dataSettings.value?.start_server_free{
                return ip
            }else{
                //найдем любой pro server
                return getAnyIpFree() ?? ""
            }
        }
    }
    
    func statusSubscribe() -> Bool{
        IAPManager.shared.checkValid()
        return UserDefaults.standard.value(forKey: UDID.subscribtion.getKey) as? Bool ?? false
    }
    
    func isNearestServer() -> Bool{
        return UserDefaults.standard.value(forKey: UDID.nearestServer.getKey) as? Bool ?? false
    }
    
    func isWithMinNumber() -> Bool{
        return UserDefaults.standard.value(forKey: UDID.minNumberServer.getKey) as? Bool ?? true
    }
    
    func isStartConnectVPN() -> Bool{
        return UserDefaults.standard.value(forKey: UDID.settingsStartUp.getKey) as? Bool ?? false
    }
    
    func defaultIpServer() -> String?{
        if let ip = UserDefaults.standard.value(forKey: UDID.defaultIP.getKey) as? String{
            if statusSubscribe() == false{
                if let server = getServer(on: ip), let statusServer = server.status, statusServer.uppercased() == StatusServer.pro.getValue.uppercased(){
                    return nil
                }else{
                    return ip
                }
            }else{
                return ip
            }
        }
        return nil
    }
    
    func getAnyIpPro() -> String?{
        for server in serverList.value{
            if let server = server, let status = server.status, status.uppercased() == StatusServer.pro.getValue.uppercased(), let ip = server.ip{
                return ip
            }
        }
        return getAnyIpFree()
    }
    
    func getServer(on ip: String) -> Server?{
        for server in serverList.value{
            if let server = server, let serverIp = server.ip, serverIp == ip{
                return server
            }
        }
        return nil
    }
    
    func getIndexServer(on server: Server?) -> Int?{
        if let server = server{
            for (index, s) in self.serverList.value.enumerated(){
                if s?.ip == server.ip, server.ip != nil{
                    return index
                }
            }
            return nil
        }else{
            return nil
        }
    }
    
    func getAnyIpFree() -> String?{
        for server in serverList.value{
            if let server = server, let status = server.status, status.uppercased() != StatusServer.pro.getValue.uppercased(), let ip = server.ip{
                return ip
            }
        }
        return nil
    }
    
    func statusServer(indexPath: IndexPath) -> StatusServer{
        if indexPath.row < serverList.value.count{
            if let serverList = serverList.value[indexPath.row], let status = serverList.status{
                if status.uppercased() == StatusServer.pro.getValue.uppercased(){
                    return .pro
                }else{
                    return .free
                }
            }
        }
        return .free
    }
    
    func getIPWithMinPing(){
        if statusSubscribe(){
            //устанавливаем ip по ping
            if let minPingPro = MinPings.shared.minPingPro{
                oldIpConnect = minPingPro.ip
                self.locationServerDelegate.locationServerViewModelType.selectedIp.accept(minPingPro.ip)
            }else{
                let ip = getAnyIpPro() ?? ""
                oldIpConnect = ip
                self.locationServerDelegate.locationServerViewModelType.selectedIp.accept(ip)
            }
        }else{
            //устанавливаем ip по ping
            if let minPingFree = MinPings.shared.minPingFree{
                oldIpConnect = minPingFree.ip
                self.locationServerDelegate.locationServerViewModelType.selectedIp.accept(minPingFree.ip)
            }else{
                let ip = getAnyIpFree() ?? ""
                oldIpConnect = ip
                self.locationServerDelegate.locationServerViewModelType.selectedIp.accept(ip)
            }
        }
    }

}
