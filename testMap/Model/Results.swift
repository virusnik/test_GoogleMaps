//
//  Items.swift
//  testMap
//
//  Created by Sergio Veliz on 10/6/18.
//  Copyright © 2018 Sergio Veliz. All rights reserved.
//

import Foundation
import ObjectMapper

class Results: Mappable {
    
    var name: String = ""
    var address: String = ""
    var geometry: Geometry = Geometry()
    
    init(){}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name        <- map["name"]
        address     <- map["vicinity"]
        geometry    <- map["geometry"]
        
    }
    
}
