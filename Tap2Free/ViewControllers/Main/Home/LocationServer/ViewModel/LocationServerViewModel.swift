//
//  LocationServerViewModel.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import RxSwift
import RxCocoa
import NetworkExtension

class LocationServerViewModel: LocationServerViewModelType{
    
    private var serverList: BehaviorRelay<[Server?]>
    var selectedIp: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    init(){
        serverList = ServerList.shared.serverList
    }
    
    func numberOfRowsInSection() -> Int {
        return serverList.value.count
    }
    
    func cellForRowAt(indexPath: IndexPath) -> LocationServerCellViewModel {
        var select = false
        if indexPath.row == getIndex(from: selectedIp.value){
            select = true
        }
        return LocationServerCellViewModel(server: serverList.value[indexPath.row], isSelected: select)
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        if let ip = serverList.value[indexPath.row]!.ip{
            self.selectedIp.accept(ip)
        }
    }
    
    private func getIndex(from ip: String) -> Int{
        for (i, server) in serverList.value.enumerated(){
            if let server = server, let ip = server.ip, ip == selectedIp.value{
                return i
            }
        }
        return 0
    }
    

    func checkStatusSubscribe() -> Bool{
           return UserDefaults.standard.value(forKey: UDID.subscribtion.getKey) as? Bool ?? false
    }
    
    func getStatusSubscribe(on indexPath: IndexPath) -> StatusServer{
        for i in StatusServer.allCases{
            if let server = serverList.value[indexPath.row], let status = server.status{
                if status.uppercased() ==  i.getValue.uppercased(){
                    return i
                }
            }
        }
        return .free
    }
    
    func changeIPConnect(on ip: String) {
        selectedIp.accept(ip)
    }
}
