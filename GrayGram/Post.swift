//
//  Post.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 7..
//  Copyright © 2017년 celia me. All rights reserved.
//

import ObjectMapper

struct Post:Mappable {
    var id:Int!
    var message:String?
    var createdAt:Date!
    
    init?(map: Map) {
        
    }
    
    // var로 정의된 구조체에만 쓸수있음. let으로 정의된 구조체에는 mapping 쓸수없음.
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.message <- map["message"]
        self.createdAt <- (map["createdAt"], ISO8601DateTransform()) // 문자열을 지정한 포맷 Date로
    }
}
