//
//  SplashViewController.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 20..
//  Copyright © 2017년 celia me. All rights reserved.
//

import Alamofire

final class SplashViewController:UIViewController{
    fileprivate let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        activityIndicatorView.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let urlString = "https://api.graygram.com/me"
        Alamofire.request(urlString)
        .validate(statusCode: 200 ..< 400)
        .responseJSON{ response in
            switch response.result {
            case .success(let value) :
                print("내 프로필 받아오기 성공 \(value)")
                AppDelegate.instance?.presentMainScreen()
            case .failure(let error) :
                print("내 프로필 받아오기 실패 \(error)")
                AppDelegate.instance?.presentLoginScreen()
            }
        }
    }
}
