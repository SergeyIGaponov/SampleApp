//
//  ControllerID.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation

enum ControllerID {
    case leftMenuNavigationController
    case settingsViewController
    case homeViewController
    case serversListViewController
    case adViewController
    case banerTryPro
    case ratingViewController
}

extension ControllerID{
    var getID: String{
        switch self {
        case .leftMenuNavigationController:
            return "LeftMenuNavigationController"
        case .settingsViewController:
            return "SettingsViewControllerID"
        case .homeViewController:
            return "HomeViewControllerID"
        case .serversListViewController:
            return "ServersListViewControllerID"
        case .adViewController:
            return "ADViewControllerID"
        case .banerTryPro:
            return "banerTryProID"
        case .ratingViewController:
            return "RatingViewControllerID"
        }
    }
}
