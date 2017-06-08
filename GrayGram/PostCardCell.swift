//
//  PostCardCell.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 8..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit

final class PostCardCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(corder:) has not been implemented")
    }
    
    func configure(post:Post) {
        self.backgroundColor = .yellow
    }
//    class func size(width:CGFloat, post:Post) -> CGSize {
//        return CGSize(width:width, height:width)
//    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//    }
}
