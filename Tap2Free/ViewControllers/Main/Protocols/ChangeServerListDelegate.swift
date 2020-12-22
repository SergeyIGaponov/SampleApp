//
//  ChangeServerListDelegate.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import NetworkExtension

protocol ChangeAppDataDelegate {
    func changeServerList(serverList : [Server?])
    
    func changeDataSettings(dataSettings : DataSettings?)
    
    func changeConfig(config : Config?)
    
    func changeStatusConnection(status: NEVPNStatus)
}
