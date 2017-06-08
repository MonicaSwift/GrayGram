//
//  File.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 8..
//  Copyright © 2017년 celia me. All rights reserved.
//

import ObjectMapper

struct User : Mappable {
    var id:Int!
    var username:String!
    var photoID:String?
    
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
        photoID <- map["photo.id"]
    }
}
