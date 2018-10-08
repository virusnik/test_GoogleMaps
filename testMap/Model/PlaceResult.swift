//
//  Place.swift
//  testMap
//
//  Created by Sergio Veliz on 10/6/18.
//  Copyright © 2018 Sergio Veliz. All rights reserved.
//

import Foundation
import ObjectMapper

class PlaceResult: Mappable {
    
    var results: [Results] = [Results]()
    
    init(){}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        results    <- map["results"]
    }
}
