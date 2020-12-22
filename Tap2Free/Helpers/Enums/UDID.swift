//
//  UDID.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation

enum UDID{
    case timeConnect
    case settingsStartUp
    case nearestServer
    case minNumberServer
    case defaultIP
    case connectIP
    case subscribtion
    case firstDateStartApp
    case bannerTryProToday
    case showRating
    case showRatingToday
}

extension UDID{
    var getKey: String{
        switch self {
        case .timeConnect:
            return "Key_TimeConnect"
        case .settingsStartUp:
            return "Key_settingsStartUp"
        case .nearestServer:
            return "Key_nearestServer"
        case .minNumberServer:
            return "Key_minNumberServer"
        case .defaultIP:
            return "Key_defaultIP"
        case .connectIP:
            return "Key_connectIP"
        case .subscribtion:
            return "Key_subscribtion"
        case .firstDateStartApp:
            return "Key_firstDateStartApp"
        case .bannerTryProToday:
            return "KEY_bannerTryProToday"
        case .showRating:
            return "KEY_showRating"
        case .showRatingToday:
            return "KEY_showRatingToday"
        }
    }
}
