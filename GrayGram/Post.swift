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
    var user:User!
    var photoID:String!
    var message:String?
    var isLiked:Bool!
    var likeCount:Int!
    var createdAt:Date!
    
    init?(map: Map) {
        
    }
    
    // var로 정의된 구조체에만 쓸수있음. let으로 정의된 구조체에는 mapping 쓸수없음.
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.user <- map["user"]
        self.photoID <- map["photo.id"]
        self.message <- map["message"]
        self.isLiked <- map["is_liked"]
        self.likeCount <- map["like_count"]
        self.createdAt <- (map["createdAt"], ISO8601DateTransform()) // 문자열을 지정한 포맷 Date로
    }
}

extension Notification.Name {
    /// 좋아요를 한 경우 발생하는 노티피케이션입니다. `userInfo`에 `postID:Int`가 전달됩니다.
    static let postDidLike:Notification.Name = .init("postDidLike")
    /// 좋아요를 취소한 경우 발생하는 노티피케이션입니다. `userInfo`에 `postID:Int`가 전달됩니다.
    static let postDidUnlike:Notification.Name = .init("postDidUnlike")
    /// 새로운 `Post`가 생성될 경우 발생합니다. `userInfo`에 `post:Post`가 전달됩니다.
    static let postDidCreate:Notification.Name = .init("postDidCreate")
}
