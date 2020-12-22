//
//  ListServers.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import ObjectMapper

class Server: BaseResponce{
    
    var flag_url : String?
    var map_url : String?
    var ip : String?
    var name: String?
    var status: String?
    var latency: Double?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        flag_url <- map["flag_url"]
        map_url <- map["map_url"]
        ip <- map["ip"]
        name <- map["name"]
        status <- map["status"]
    }
}
