//
//  PostCardCell.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 8..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit
import Alamofire

final class PostCardCell: UICollectionViewCell {
    fileprivate enum Metric {
        static let avatarViewTop: CGFloat = 0
        static let avatarViewLeft: CGFloat = 10
        static let avatarViewSize: CGFloat = 30
        
        /// avatarView의 오른쪽 간격
        static let usernameLabelLeft: CGFloat = 10
        static let usernameLabelRight: CGFloat = 10
        
        static let pictureViewTop: CGFloat = 10
        
        static let likeButtonTop: CGFloat = 10
        static let likeButtonLeft: CGFloat = 10
        static let likeButtonSize: CGFloat = 20
        
        static let likeCountLabelLeft: CGFloat = 10
        static let likeCountLabelRight: CGFloat = 10
        
        static let messageLabelTop: CGFloat = 10
        static let messageLabelLeft: CGFloat = 10
        static let messageLabelRight: CGFloat = 10
    }
    
    fileprivate enum Font {
        static let usernameLabel = UIFont.boldSystemFont(ofSize: 13)
        static let likeCountLabel = UIFont.boldSystemFont(ofSize: 13)
        static let messageLabel = UIFont.systemFont(ofSize: 14)
    }

    fileprivate let avatarView = UIImageView()
    fileprivate let usernameLabel = UILabel()
    fileprivate let pictureView = UIImageView()
    fileprivate let likeButton = UIButton()
    fileprivate let likeCountLabel = UILabel()
    fileprivate let messageLabel = UILabel()
    
    fileprivate var post:Post?
    
    // 1. 생성자
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 속성 초기화
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = Metric.avatarViewSize / 2
        
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        usernameLabel.textColor = .black
        likeButton.setBackgroundImage(UIImage(named:"icon-like"), for: .normal)
        likeButton.setBackgroundImage(#imageLiteral(resourceName: "icon-like-selected"), for: .selected)
        likeButton.addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
        
        likeCountLabel.font = UIFont.boldSystemFont(ofSize: 12)
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.numberOfLines = 3
        
        // addSubView
        self.contentView.addSubview(avatarView)
        self.contentView.addSubview(usernameLabel)
        self.contentView.addSubview(pictureView)
        self.contentView.addSubview(likeButton)
        self.contentView.addSubview(likeCountLabel)
        self.contentView.addSubview(messageLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(corder:) has not been implemented")
    }
    
    // 2. 설정 : 이 셀이 UI를 표시하기 위한 데이터를 파라미터로 받아서 서브뷰의 데이터를 채움
    func configure(post:Post) {
        print("configure")
        self.post = post
        
        avatarView.setImage(photoID: post.user.photoID, size: .tiny)
        
        usernameLabel.text = post.user.username
        
        pictureView.setImage(photoID: post.photoID, size: .large)
        
        likeButton.isSelected = post.isLiked
        
        likeCountLabel.text = "\(post.likeCount ?? 0)명이 좋아합니다."
        
        messageLabel.text = post.message
        
        setNeedsLayout()
    }
    
    // 3. 크기 : 컬렉션 뷰의 너비를 받고, 이 셀의 크기를 계산하기위해 필요한 데이터를 받아 사이즈를 설정
    class func size(width:CGFloat, post:Post) -> CGSize {
        print("size")
        var height: CGFloat = 0
        
        height += Metric.avatarViewTop
        height += Metric.avatarViewSize
        
        height += Metric.pictureViewTop
        height += width // picture의 높이
        
        height += Metric.likeButtonTop
        height += Metric.likeButtonSize
        
        // 공백문자도 높이 없애기 위해 isEmpty체크 넣어줌
        if let message = post.message, !message.isEmpty {
            let messageLabelWidth = width - Metric.messageLabelLeft - Metric.messageLabelRight
            height += Metric.messageLabelTop
            height += message.size(
                width: messageLabelWidth,
                font: Font.messageLabel,
                numberOfLines: 3
                ).height
        }
        
        return CGSize(width: width, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews()")
        
        // avatar view
        avatarView.x = Metric.avatarViewLeft
        avatarView.y = Metric.avatarViewTop
        avatarView.width = Metric.avatarViewSize
        avatarView.height = Metric.avatarViewSize
        
        // username label
        usernameLabel.left = avatarView.right + Metric.usernameLabelLeft
        usernameLabel.sizeToFit()
        usernameLabel.width = min(
            usernameLabel.width,
            contentView.width - Metric.usernameLabelRight - usernameLabel.left
        )
        usernameLabel.centerY = avatarView.centerY
        
        // picture view
        pictureView.width = contentView.width
        pictureView.height = pictureView.width
        pictureView.top = avatarView.bottom + Metric.pictureViewTop
        
        // like button
        likeButton.width = Metric.likeButtonSize
        likeButton.height = Metric.likeButtonSize
        likeButton.left = Metric.likeButtonLeft
        likeButton.top = pictureView.bottom + Metric.likeButtonTop
        
        // like count label
        likeCountLabel.left = likeButton.right + Metric.likeCountLabelLeft
        likeCountLabel.sizeToFit()
        likeCountLabel.width = min(
            likeCountLabel.width,
            contentView.width - Metric.likeCountLabelRight - likeCountLabel.left
        )
        likeCountLabel.centerY = likeButton.centerY
        
        // message label
        messageLabel.top = likeButton.bottom + Metric.messageLabelTop
        messageLabel.left = Metric.messageLabelLeft
        messageLabel.width = contentView.width - Metric.messageLabelRight - messageLabel.left
        messageLabel.sizeToFit()
        
        // 한줄:  sizeToFit -> width 설정
        // 여러줄: width 설정 -> sizeToFit
    }
    
    func likeButtonDidTap() {
    
        guard let post = self.post else { return }
        let urlString = "https://api.graygram.com/posts/\(post.id!)/likes"
        
        if !likeButton.isSelected {
            var newPost = post
            newPost.isLiked = true
            newPost.likeCount! += 1
            self.configure(post: newPost)
            
            NotificationCenter.default.post(name: .postDidLike, object: self, userInfo: ["postID":post.id])
            
            Alamofire.request(urlString, method: .post)
                .validate(statusCode: 200 ..< 400)
                .responseData{ response in
                    switch response.result {
                    case .success :
                        print("좋아요 성공 \(post.id!)")
                    case .failure :
                        if response.response?.statusCode != 409 {
                            print("좋아요 실패")
                            self.configure(post: post)
                            NotificationCenter.default.post(name: .postDidUnlike, object: self, userInfo: ["postID":post.id])
                        }
                    }
            }
        } else {
            var newPost = post
            newPost.isLiked = false
            newPost.likeCount! -= 1
            self.configure(post: newPost)

            NotificationCenter.default.post(name: .postDidUnlike, object: self, userInfo: ["postID":post.id])
            
            Alamofire.request(urlString, method: .delete)
                .validate(statusCode: 200 ..< 400)
                .responseData{ response in
                    switch response.result {
                    case .success :
                        print("좋아요 해제 성공 \(post.id!)")
                    case .failure :
                        if response.response?.statusCode != 409 {
                            print("좋아요 해제 실패")
                            self.configure(post: post)
                            NotificationCenter.default.post(name: .postDidLike, object: self, userInfo: ["postID":post.id])
                        }
                    }
            }
        }
        

    }
}
