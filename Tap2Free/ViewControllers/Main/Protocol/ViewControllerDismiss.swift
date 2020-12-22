//
//  ViewControllerDismiss.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation


protocol ViewControllerDismiss {
    func dismissViewController(completion: @escaping (() -> ()))
    func showRating()
}
