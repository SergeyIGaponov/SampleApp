//
//  Tittles.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation

enum TitlesAlerts{
    case error
    case warning
    case textWarning
}

extension TitlesAlerts{
    var getValue : String{
        switch self {
        case .error:
            return "Error"
        case .warning:
            return "Warning"
        case .textWarning:
            return "An important update, Please update the app!"
        }
    }
}

enum TitleAlertButton{
    case ok
    case cancel
    case update
}

extension TitleAlertButton{
    var getValue: String{
        switch self {
        case .cancel:
            return "Cancel"
        case .ok:
            return "OK"
        case .update:
            return "Update"
        }
    }
}

enum TitleUI{
    case connect
    case disconnect
}

extension TitleUI{
    var getTitle: String{
        switch self {
        case .connect:
            return "Connect to VPN Server"
        case .disconnect:
            return "Disconnect"
        }
    }
}

enum URLsApp{
    case share
}

extension URLsApp{
    var getUrl: String{
        switch self {
        case .share:
            return "https://itunes.apple.com/ru/app/"
        }
    }
}
