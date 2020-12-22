//
//  ConfigData.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import RxSwift
import RxCocoa

class ConfigData{
    static var shared = ConfigData()
 
    var config: BehaviorRelay<Config?> = BehaviorRelay(value: nil)
    
    private let delegate = UIApplication.shared.delegate as! AppDelegate
    
    func requestConfig(from ip: String, url: BaseUrl){
        Tap2FreeAPI.requstTap2FreeObject(type: Config.self,
                                         request: FiosServersServerAPI.getConfig(url: url.getUrl, ip: ip),
                                         delegate: delegate) {[weak self] responce in
            if responce?.config != nil{
                self?.config.accept(responce)
            }else{
                if url == .url{
                    self?.requestConfig(from: ip, url: .reserveUrl)
                }else{
                    self?.config.accept(nil)
                }
            }
        }
    }
}
