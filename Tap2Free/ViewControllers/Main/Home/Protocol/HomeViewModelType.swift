//
//  HomeViewModelType.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import RxSwift
import RxCocoa

protocol HomeViewModelType{
    var serverList: BehaviorRelay <[Server?]> {get}
    var config: BehaviorRelay<Config?> {get}
    var dataSettings: BehaviorRelay<DataSettings?> {get}
    var needConnectType: Bool {get}
    func isStartConnectVPN() -> Bool
}

protocol HomeViewModelServerType {
    var serverList: BehaviorRelay <[Server?]> {get}
    var dataSettings: BehaviorRelay<DataSettings?> {get}
    func getIpServerFromDataSettings(for status: StatusServer) -> String
    func statusSubscribe() -> Bool
    func defaultIpServer() -> String?
    func getAnyIpPro() -> String?
    func getServer(on ip: String) -> Server?
    func getIndexServer(on server: Server?) -> Int?
    func getAnyIpFree() -> String?
    func statusServer(indexPath: IndexPath) -> StatusServer
}
