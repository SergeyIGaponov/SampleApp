//
//  DataSettings.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import Foundation
import ObjectMapper

class DataSettings: BaseResponce {
    
    var min_version : String?
    var connect_ads : Int?
    var connect_ads_day : Int?
    var try_pro_always_on_startup : Int?
    var day_try_pro: String?
    var start_server_pro : String?
    var start_server_free : String?
    var local_ip_pro : String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        min_version <- map["min_version"]
        connect_ads <- map["connect_ads"]
        connect_ads_day <- map["connect_ads_day"]
        try_pro_always_on_startup <- map["try_pro_always_on_startup"]
        day_try_pro <- map["day_try_pro"]
        start_server_pro <- map["start_server_pro"]
        start_server_free <- map["start_server_free"]
        local_ip_pro <- map["local_ip_pro"]
    }
}
