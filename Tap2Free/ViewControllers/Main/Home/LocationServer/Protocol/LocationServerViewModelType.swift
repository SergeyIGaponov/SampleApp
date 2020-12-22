//
//  LocationServerViewModelType.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import NetworkExtension
import RxSwift
import RxCocoa

protocol LocationServerViewModelType {
    func numberOfRowsInSection() -> Int
    func cellForRowAt(indexPath: IndexPath) -> LocationServerCellViewModel
    func didSelectRowAt(indexPath: IndexPath)
    func checkStatusSubscribe() -> Bool
    func getStatusSubscribe(on indexPath: IndexPath) -> StatusServer
    func changeIPConnect(on ip: String)
  
    var selectedIp: BehaviorRelay<String> {get set}
}
