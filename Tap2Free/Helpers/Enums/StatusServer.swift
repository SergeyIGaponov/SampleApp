//
//  StatusServer.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import UIKit

enum StatusServer: CaseIterable{
    case pro
    case free
    case personal
}

extension StatusServer{
    var getValue: String{
        switch self {
        case .free:
            return "Free"
        case .pro:
            return "PRO"
        case .personal:
            return "Personal"
        }
    }
    
    var backgroundColor: UIColor{
        switch self {
        case .free:
            return #colorLiteral(red: 0.831372549, green: 0.831372549, blue: 0.831372549, alpha: 1)
        case .personal:
            return #colorLiteral(red: 0.3825896382, green: 0.8006353974, blue: 0.9381121397, alpha: 1)
        case .pro:
            return #colorLiteral(red: 0.5557940602, green: 0.8436309695, blue: 0.1671362221, alpha: 1)
        }
    }
}
