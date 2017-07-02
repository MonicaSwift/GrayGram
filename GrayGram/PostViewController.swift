//
//  PostViewController.swift
//  GrayGram
//
//  Created by celia me on 2017. 7. 2..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit

final class PostViewController:UIViewController {
    fileprivate let postID:Int
    
    init(postID:Int) {
        self.postID = postID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.view.backgroundColor = .white
    }
}
