//
//  BaseUrl.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
enum BaseUrl{
    case url
    case reserveUrl
}
extension BaseUrl{
    var getUrl : URL {
        switch self {
        case .url:
            return URL(string: "http://api.net/api/")!
        case .reserveUrl:
            return URL(string: "http://fastvpn.site/api/")!
        }
    }
}
