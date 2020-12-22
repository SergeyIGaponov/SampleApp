//
//  IAPProducts.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation

enum IAAProducts{
    case oneMonth
    case oneYear
    case sixMonth
}

extension IAAProducts{
    var getID: String{
        switch self {
        case .oneMonth:
            return "com.altcoinapps.Tap2Free.oneMonth"
        case .sixMonth:
            return "com.altcoinapps.Tap2Free.sixMonth"
        case .oneYear:
            return "com.altcoinapps.Tap2Free.oneYear"
        }
    }
}
