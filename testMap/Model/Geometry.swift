//
//  Geometry.swift
//  testMap
//
//  Created by Sergio Veliz on 10/7/18.
//  Copyright © 2018 Sergio Veliz. All rights reserved.
//

import Foundation
import ObjectMapper

class Geometry: Mappable {
    
    var location: Location = Location()
    
    init(){}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        location    <- map["location"]
        
    }
    
}
