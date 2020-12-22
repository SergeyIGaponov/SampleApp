//
//  DataSettingsApp.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import RxSwift
import RxCocoa

class DataSettingsApp{
    static var shared = DataSettingsApp()
    
    var dataSettings: BehaviorRelay<DataSettings?> = BehaviorRelay(value: nil)
    
    private let delegate = UIApplication.shared.delegate as! AppDelegate
    
    init(){
        self.requestDataSettings(url: .url)
    }
    
    fileprivate func requestDataSettings(url: BaseUrl){
        Tap2FreeAPI.requstTap2FreeObject(type: DataSettings.self, request: FiosServersServerAPI.getSittings(url: url.getUrl), delegate: delegate) {[weak self] responce in
            if responce != nil{
                self?.dataSettings.accept(responce)
            }else{
                if url == .url{
                    self?.requestDataSettings(url: .reserveUrl)
                }else{
                    self?.dataSettings.accept(nil)
                }
            }
        }
    }

}
