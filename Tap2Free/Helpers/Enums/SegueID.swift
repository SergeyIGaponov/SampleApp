//
//  SegueID.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation

enum SegueID {
    case segueLocationServer
    case segueSettingsLocationServer
    case segueBanerTryPro
    case segueRatingViewController
    case segueServerList
    case segueSettings
    case segueRemoveAdNav
}

extension SegueID{
    var getID: String{
        switch self {
        case .segueLocationServer:
            return "segueLocationServer"
        case .segueSettingsLocationServer:
            return "segueSettingsLocationServer"
        case .segueBanerTryPro:
            return "segueBanerTryProID"
        case .segueRatingViewController:
            return "segueRatingViewControllerID"
        case .segueServerList:
            return "segueServerList"
        case .segueSettings:
            return "segueSettings"
        case .segueRemoveAdNav:
            return "segueRemoveAdNav"
        }
    }
}
