//
//  Tap2FreeServerAPI.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import Moya
import Alamofire

class DefaultAlamofireManager : Alamofire.Session{
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = nil
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return DefaultAlamofireManager(configuration: configuration)
    }()
}

enum FiosServersServerAPI{
    case getFiosServers(url: URL)
    case getSittings(url: URL)
    case getConfig(url: URL, ip: String)
}

extension FiosServersServerAPI: TargetType{
    var baseURL: URL {
        switch self {
        case .getConfig(let url, _):
            return url
        case .getFiosServers(let url):
            return url
        case .getSittings(let url):
            return url
        }
    }
    
    var path: String {
        switch self {
        case .getFiosServers:
            return "t2fios-servers"
        case .getSittings:
            return "t2fios-settings"
        case .getConfig:
            return "t2fios-server"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .getConfig(let _, let ip):
            return .requestParameters(parameters: ["ip" : ip], encoding: URLEncoding.default)
        default: return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["app_id":""]
    }
    
    
}
