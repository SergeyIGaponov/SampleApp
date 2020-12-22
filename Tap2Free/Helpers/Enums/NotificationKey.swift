//
//  NotificationKey.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation

enum NotificationKey {
    case rewardBasedVideoAdDidReceive
}

extension NotificationKey{
    var getName: String{
        switch self {
        case .rewardBasedVideoAdDidReceive:
            return "rewardBasedVideoAdDidReceive"
        }
    }
}
