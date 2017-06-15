//
//  CollectionActivityIndicatorView.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 15..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit

final class CollectionActivityIndicatorView:UICollectionReusableView {
    fileprivate let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        activityIndicatorView.startAnimating()
        self.addSubview(activityIndicatorView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(corder:) has not been implementd")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.centerX = self.width / 2
        activityIndicatorView.centerY = self.height / 2
    }
}
