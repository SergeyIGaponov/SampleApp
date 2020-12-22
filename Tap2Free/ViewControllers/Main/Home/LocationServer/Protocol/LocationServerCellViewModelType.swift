//
//  LocationServerCellViewModelType.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import UIKit

protocol LocationServerCellViewModelType: class {
    var urlImageFlag: URL? {get}
    var serverName: String? {get}
    var isHiddenStatusView: Bool {get}
    var backgroundColorStatusView: UIColor {get}
    var contentBackground: UIColor? {get}
    var status: String? {get}
    var signalPing: UIImage? {get}
    var isFast: Bool {get}
}
