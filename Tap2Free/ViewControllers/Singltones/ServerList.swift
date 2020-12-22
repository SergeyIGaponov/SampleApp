//
//  ServerList.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import RxSwift
import RxCocoa
import UIKit
import PlainPing

class ServerList{
    
    static var shared = ServerList()
 
    var serverList: BehaviorRelay<[Server?]> = BehaviorRelay(value: [])
    var minPings = MinPings.shared

    private let delegate = UIApplication.shared.delegate as! AppDelegate
    
    init() {
    }
    
    //MARK:- Request GetServerList
    public func requestListServers(url: BaseUrl){
        Tap2FreeAPI.requstTap2FreeArrays(type: Server.self, request: FiosServersServerAPI.getFiosServers(url: url.getUrl), delegate: delegate) {[weak self] (responce)  in
            if responce.count > 0{
                OverlaysVariable.shared.changeOverlays(on: .show)
                self?.pingNext(serverList: responce, index: 0, callback: {
                    [weak self] serverList in
                    self?.serverList.accept(serverList)
                    OverlaysVariable.shared.changeOverlays(on: .hide)
                })
            }else{
                if url == .url{
                    self?.requestListServers(url: .reserveUrl)
                }else{
                    self?.serverList.accept([])
                }
            }
        }
    }
    
    func pingNext(serverList: [Server?], index: Int, callback: @escaping ([Server?])->()) {
        if index < serverList.count, let element = serverList[index], let ip = element.ip{
            PlainPing.ping(ip, withTimeout: 1.0) { [weak self] (timeElapsed: Double?, error: Error?) in
                if let latency = timeElapsed {
                    if let self = self, let status = element.status, let ip = element.ip{
                        for i in StatusServer.allCases{
                            if i.getValue.uppercased() == status.uppercased(){
                                switch i {
                                case .pro:
                                    if let minPingPro = self.minPings.minPingPro{
                                        if latency < minPingPro.latency{
                                            let newMinPing = MinPing(ip: ip, latency: latency)
                                            self.minPings.setMinPingPro(minPing: newMinPing)
                                        }
                                    }else{
                                        let newMinPing = MinPing(ip: ip, latency: latency)
                                        self.minPings.setMinPingPro(minPing: newMinPing)
                                    }
                                default:
                                    if let minPingFree = self.minPings.minPingFree{
                                        if latency < minPingFree.latency{
                                            let newMinPing = MinPing(ip: ip, latency: latency)
                                            self.minPings.setMinPingFree(minPing: newMinPing)
                                        }
                                    }else{
                                        let newMinPing = MinPing(ip: ip, latency: latency)
                                        self.minPings.setMinPingFree(minPing: newMinPing)
                                    }
                                }
                            }
                        }
                    }
                    serverList[index]?.latency = latency
                    self?.pingNext(serverList: serverList, index: index + 1, callback: { serverList in
                        callback(serverList)
                    })
                }else{
                    serverList[index]?.latency = 200.0
                    self?.pingNext(serverList: serverList, index: index + 1, callback: { serverList in
                        callback(serverList)
                    })
                }
            }
        }else{
            callback(serverList)
        }
    }
    
}

class MinPings {
    
    static let shared = MinPings()
    
    var minPingPro: MinPing?
    var minPingFree: MinPing?
    
    func setMinPingPro(minPing: MinPing){
        self.minPingPro = minPing
    }
    
    func setMinPingFree(minPing: MinPing){
        self.minPingFree = minPing
    }
}

class MinPing{
    var ip: String
    var latency: Double
    
    init (ip: String, latency: Double){
        self.ip = ip
        self.latency = latency
    }
}
