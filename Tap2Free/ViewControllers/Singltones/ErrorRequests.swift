//
//  ErrorRequests.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import RxSwift
import RxCocoa

class ErrorRequests{
    static var errorRequestApi: BehaviorRelay<ErrorVPNApi?> = BehaviorRelay(value: nil)
    
    
    static func setError(error: ErrorVPNApi?){
        if errorRequestApi.value == nil{
            errorRequestApi.accept(error)
        }else{
            if error == nil{
                errorRequestApi.accept(nil)
            }
        }
    }
}
