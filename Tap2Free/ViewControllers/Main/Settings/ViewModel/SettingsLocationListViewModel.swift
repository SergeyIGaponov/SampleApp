//
//  SettingsLocationListViewModel.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation

class SettingsLocationListViewModel: SettingsLocationListViewType{
    
    private var isSelect: IndexPath = IndexPath(row: 0, section: 0)
    private let serverType: HomeViewModelServerType
    
    init(serverType: HomeViewModelServerType) {
        self.serverType = serverType
        
        //выбран ли сервер ранее
        //получить сервер из списка серверов
        //получаем статус сервера
        if let defIp = serverType.defaultIpServer(),
            let server = serverType.getServer(on: defIp){
            if let statusServer = server.status, statusServer.uppercased() == StatusServer.pro.getValue.uppercased(){
                //проверяем если выбранный сервер является про и подписка оформлена
                if serverType.statusSubscribe(){
                    if let index = serverType.getIndexServer(on: server){
                        //устанавливаем сервер
                        isSelect = IndexPath(row: index, section: 0)
                    }else{
                        //не удалось найти сервер в списке
                        //получаем default server из конфигурации
                        let ip = serverType.getIpServerFromDataSettings(for: .pro)
                        if let index = serverType.getIndexServer(on: serverType.getServer(on: ip)){
                            isSelect = IndexPath(row: index, section: 0)
                        }else{
                            //не удалось найти сервер из конфигурации в списке
                            //выбираем любой pro server
                            let index = serverType.getIndexServer(on: serverType.getServer(on: serverType.getAnyIpPro() ?? ""))!
                            isSelect = IndexPath(row: index, section: 0)
                        }
                    }
                }else{
                    //подписка не оформлена
                    //получаем default server из конфигурации
                    //удаляем установленный сервер
                    let ip = serverType.getIpServerFromDataSettings(for: .free)
                    if let index = serverType.getIndexServer(on: serverType.getServer(on: ip)){
                        isSelect = IndexPath(row: index, section: 0)
                    }else{
                        //не удалось найти сервер
                        //выбираем любой бесплатный сервер
                        let index = serverType.getIndexServer(on: serverType.getServer(on: serverType.getAnyIpFree() ?? ""))!
                        isSelect = IndexPath(row: index, section: 0)
                    }
                    UserDefaults.standard.removeObject(forKey: UDID.defaultIP.getKey)
                }
            }else{
                //выбранный ранее сервер есть free
                if let index = serverType.getIndexServer(on: server){
                    //устанавливаем сервер
                    isSelect = IndexPath(row: index, section: 0)
                }else{
                    //не удалось найти сервер в списке
                    //получаем default server из конфигурации
                    let ip = serverType.getIpServerFromDataSettings(for: .free)
                    if let index = serverType.getIndexServer(on: serverType.getServer(on: ip)){
                        isSelect = IndexPath(row: index, section: 0)
                    }else{
                        //не удалось найти сервер из конфигурации в списке
                        //выбираем любой free server
                        let index = serverType.getIndexServer(on: serverType.getServer(on: serverType.getAnyIpFree() ?? ""))!
                        isSelect = IndexPath(row: index, section: 0)
                    }
                }
            }
        }else{
            //сервер не выбирался или не был найден в списке
            if serverType.statusSubscribe(){
                //выбираем из настроек pro сервер
                let ip = serverType.getIpServerFromDataSettings(for: .pro)
                if let index = serverType.getIndexServer(on: serverType.getServer(on: ip)){
                    isSelect = IndexPath(row: index, section: 0)
                }else{
                    //не удалось найти сервер из конфигурации в списке
                    //выбираем любой pro server
                    let index = serverType.getIndexServer(on: serverType.getServer(on: serverType.getAnyIpPro() ?? ""))!
                    isSelect = IndexPath(row: index, section: 0)
                }
            }else{
                //получаем default server из конфигурации
                let ip = serverType.getIpServerFromDataSettings(for: .free)
                if let index = serverType.getIndexServer(on: serverType.getServer(on: ip)){
                    isSelect = IndexPath(row: index, section: 0)
                }else{
                    //не удалось найти сервер из конфигурации в списке
                    //выбираем любой free server
                    let index = serverType.getIndexServer(on: serverType.getServer(on: serverType.getAnyIpFree() ?? ""))!
                    isSelect = IndexPath(row: index, section: 0)
                }
            }
        }
    }
    
    func numberOfRowsInSection() -> Int {
        return serverType.serverList.value.count
    }
    
    func cellForRowAt(indexPath: IndexPath) -> LocationServerCellViewModel {
        var isSelected = false
        if indexPath.row == isSelect.row{
            isSelected = true
        }
        return LocationServerCellViewModel(server:
            serverType.serverList.value[indexPath.row], isSelected: isSelected)
    }
    
    func didSelectAt(indexPath: IndexPath) {
        if serverType.statusServer(indexPath: indexPath) == .free{
            self.isSelect = indexPath
            if let server = serverType.serverList.value[indexPath.row], let ip = server.ip{
                UserDefaults.standard.set(ip, forKey: UDID.defaultIP.getKey)
            }
        }else{
            //проверяем активирована ли про подписка
            if serverType.statusSubscribe(){
                self.isSelect = indexPath
                if let server = serverType.serverList.value[indexPath.row], let ip = server.ip{
                    UserDefaults.standard.set(ip, forKey: UDID.defaultIP.getKey)
                }
            }
        }
    }
    
    func getIndexSelectServer() -> IndexPath {
        return isSelect
    }
    
}
