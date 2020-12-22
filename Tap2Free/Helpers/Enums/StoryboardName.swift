//
//  StoryboardName.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation

enum StoryboardName {
    case Main
    case Subscibe
}

extension StoryboardName{
    var getName : String{
        switch self {
        case .Main:
            return "Main"
        case .Subscibe:
            return "Subscibe"
        }
    }
}
