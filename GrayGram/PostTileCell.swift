//
//  PostTileCell.swift
//  GrayGram
//
//  Created by celia me on 2017. 7. 1..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit

final class PostTileCell:UICollectionViewCell {
    fileprivate let imageView = UIImageView()
    fileprivate var post:Post?
    var didTap:(() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        
        let tabGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(contentViewDidTab))
        self.contentView.addGestureRecognizer(tabGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(post:Post) {
        self.post = post
        self.imageView.setImage(photoID: post.photoID, size: .medium)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.width = self.contentView.width
        self.imageView.height = self.contentView.height
    }
    
    class func size(width:CGFloat) -> CGSize {
        return CGSize(width: width, height: width)
    }
    
    func contentViewDidTab() {
        self.didTap?()
    }
}
