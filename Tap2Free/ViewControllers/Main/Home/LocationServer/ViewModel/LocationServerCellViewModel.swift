//
//  LocationServerCellViewModel.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import UIKit

class LocationServerCellViewModel: LocationServerCellViewModelType{
    private let server: Server?
    private let isSelected: Bool
    
    init(server: Server?, isSelected: Bool){
        self.server = server
        self.isSelected = isSelected
    }
    
    var urlImageFlag: URL?{
        guard let server = server, let flagUrl = server.flag_url else {
            return nil
        }
        return URL(string: flagUrl)
    }
    
    var serverName: String?{
        return server?.name
    }
    
    var isHiddenStatusView: Bool{
        if let server = server, server.status != nil{
            return false
        }
        return true
    }
    
    var backgroundColorStatusView: UIColor{
        if let server = server, let status = server.status{
            for i in StatusServer.allCases{
                if i.getValue.lowercased() == status.lowercased(){
                    return i.backgroundColor
                }
            }
        }
        return #colorLiteral(red: 0.831372549, green: 0.831372549, blue: 0.831372549, alpha: 1)
    }
    
    var contentBackground: UIColor?{
        if isSelected{
            return #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 0.21)
        }else{
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var status: String?{
        if let server = server, let status = server.status{
            for i in StatusServer.allCases{
                if i.getValue.lowercased() == status.lowercased(){
                    return i.getValue
                }
            }
        }
        return nil
    }
    
    
    var signalPing: UIImage?{
        if let server = server, let latency = server.latency{
            switch latency{
            case 0...50:
                return #imageLiteral(resourceName: "4Line")
            case 50...100:
                return #imageLiteral(resourceName: "3Line")
            case 100...150:
                return #imageLiteral(resourceName: "2Line")
            default:
                return #imageLiteral(resourceName: "1Line")
            }
        }
        
        return nil
    }
    
    var isFast: Bool{
        if let server = server, let latency = server.latency , latency <= 50{
            return false
        }else{
            return true
        }
        
    }
}
