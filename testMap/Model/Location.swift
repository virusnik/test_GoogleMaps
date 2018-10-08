//
//  Location.swift
//  testMap
//
//  Created by Sergio Veliz on 10/7/18.
//  Copyright © 2018 Sergio Veliz. All rights reserved.
//

import Foundation
import ObjectMapper

class Location: Mappable {
    
    var lat: Double = 0.0
    var lng: Double = 0.0
    
    init(){}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        lat     <- map["lat"]
        lng     <- map["lng"]
    }
    
}
