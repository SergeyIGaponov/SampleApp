//
//  OverlaysVariable.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import RxSwift
import RxCocoa
import SwiftOverlayShims

class OverlaysVariable{
    static let shared = OverlaysVariable()
    var overlay: BehaviorRelay<Overlay> = BehaviorRelay(value: .hide)
    
    func changeOverlays(on overlay: Overlay){
        if self.overlay.value != overlay{
            self.overlay.accept(overlay)
        }
    }
}

enum Overlay {
    case show
    case hide
}
