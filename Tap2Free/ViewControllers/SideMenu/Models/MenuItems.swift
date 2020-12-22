//
//  MenuItems.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation

enum MenuItems: CaseIterable{
    case connection
    case serverList
    case settings
    case removeAd
    case feedback
    case support
}

extension MenuItems{
    var tag: Int{
        switch self {
        case .connection:
            return 0
        case .serverList:
            return 1
        case .settings:
            return 2
        case .removeAd:
            return 3
        case .feedback:
            return 4
        default:
            return 5
        }
    }
    
    var segueId: SegueID?{
        switch self {
        case .connection:
            return nil
        case .feedback:
            return nil
        case .removeAd:
            return SegueID.segueRemoveAdNav
        case .serverList:
            return SegueID.segueServerList
        case .settings:
            return SegueID.segueSettings
        case .support:
            return nil
        }
    }
}
