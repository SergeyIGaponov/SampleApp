//
//  Tap2FreeAPI.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import Moya
import Moya_ObjectMapper
import RxSwift
import ObjectMapper
import Alamofire
import SwiftOverlays


class Tap2FreeAPI{
    static func requstTap2FreeArrays <T>(type: T.Type, request: FiosServersServerAPI, delegate:AppDelegate, callback: @escaping ([T?])->()) where T : BaseResponce{
      
        OverlaysVariable.shared.changeOverlays(on: .show)
        
        delegate.providerFiosServersServerAPI.rx.request(request).mapArray(T.self).asObservable().subscribe(onNext: { responce in
            callback(responce)
            
            OverlaysVariable.shared.changeOverlays(on: .hide)
            
        }, onError: { (e) in
            OverlaysVariable.shared.changeOverlays(on: .hide)
          
            if request.baseURL == BaseUrl.reserveUrl.getUrl{
                let error = e as! MoyaError
                let errorVPNApi = ErrorVPNApi(errorLocalazible: error.localizedDescription)
                ErrorRequests.setError(error: errorVPNApi)
            }
            
            callback([])
        }, onCompleted: nil, onDisposed: nil).disposed(by: delegate.disposeBag)
        
    }
    
    static func requstTap2FreeObject <T>(type: T.Type, request: FiosServersServerAPI, delegate:AppDelegate, callback: @escaping (T?)->()) where T : BaseResponce{
        
        OverlaysVariable.shared.changeOverlays(on: .show)
        
        delegate.providerFiosServersServerAPI.rx.request(request).mapObject(T.self).asObservable().subscribe(onNext: { responce in
            callback(responce)
            
            OverlaysVariable.shared.changeOverlays(on: .hide)
            
        }, onError: { (e) in
            
            OverlaysVariable.shared.changeOverlays(on: .hide)
            
            if request.baseURL == BaseUrl.reserveUrl.getUrl{
                let error = e as! MoyaError
                let errorVPNApi = ErrorVPNApi(errorLocalazible: error.localizedDescription)
                ErrorRequests.setError(error: errorVPNApi)
            }
            callback(nil)
        }, onCompleted: nil, onDisposed: nil).disposed(by: delegate.disposeBag)
        
    }
}
