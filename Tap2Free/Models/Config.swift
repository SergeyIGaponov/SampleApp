//
//  Config.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import ObjectMapper

class Config: BaseResponce{
    
    var ip : String?
    var config : String?
    
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        ip <- map["ip"]
        config <- map["config"]
    }
}
