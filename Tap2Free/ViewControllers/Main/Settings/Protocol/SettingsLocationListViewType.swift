//
//  SettingsLocationListViewType.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation

protocol SettingsLocationListViewType{
    func numberOfRowsInSection() -> Int
    func cellForRowAt (indexPath: IndexPath) -> LocationServerCellViewModel
    func didSelectAt(indexPath: IndexPath)
    func getIndexSelectServer() -> IndexPath
}
