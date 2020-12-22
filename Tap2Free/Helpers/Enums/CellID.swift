//
//  CellID.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation

enum CellID {
    case locationServerTableViewCell
}

extension CellID{
    var getId: String{
        switch self {
        case .locationServerTableViewCell:
            return "LocationServerTableViewCellID"
        }
    }
}
