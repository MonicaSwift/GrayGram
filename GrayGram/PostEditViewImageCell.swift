//
//  PostEditViewImageCell.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 27..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit

final class PostEditViewImageCell:UITableViewCell {
    fileprivate let photoView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(photoView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image:UIImage) {
        self.photoView.image = image
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.photoView.width = self.contentView.width
        self.photoView.height = self.contentView.height
    }
    
    class func height(width:CGFloat) -> CGFloat {
        return width
    }
}
