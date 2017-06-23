//
//  MainTabBarController.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 23..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit

final class MainTabBarController:UITabBarController {
    
    let feedViewController = FeedViewController()
    let settingsViewController = UIViewController()
    // 업로드 버튼 역할을 할 가짜 뷰컨트롤러. 실제로 선택은 되지 않습니다.
    fileprivate let fakeUploadViewController = UIViewController()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = self
        
        self.settingsViewController.title = "Settings"
        self.settingsViewController.tabBarItem.image = UIImage(named: "tab-settings")
        self.settingsViewController.tabBarItem.selectedImage = UIImage(named: "tab-settings-selected")
        
        self.fakeUploadViewController.tabBarItem.image = UIImage(named: "tab-upload")
        self.fakeUploadViewController.tabBarItem.imageInsets.top = 5
        self.fakeUploadViewController.tabBarItem.imageInsets.bottom = -5
        
        self.viewControllers = [
            UINavigationController(rootViewController: self.feedViewController),
            UINavigationController(rootViewController: self.settingsViewController),
            self.fakeUploadViewController,
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func presentImagePickerController() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        self.present(pickerController, animated:true, completion: nil)
        
    }
}

extension MainTabBarController:UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController === self.fakeUploadViewController {
            self.presentImagePickerController()
            return false
        } else {
            return true
        }
    }
}

extension MainTabBarController:UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //print(info)
        /*
         info
         ["UIImagePickerControllerMediaType": public.image, 
         "UIImagePickerControllerReferenceURL": assets-library://asset/asset.PNG?id=162EF7CA-6A32-4F1D-987A-5FBEBAD6B1AD&ext=PNG, 
         "UIImagePickerControllerOriginalImage": <UIImage: 0x608000292a70> size {300, 730} orientation 0 scale 1.000000]
         */
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
    }
}

extension MainTabBarController:UINavigationControllerDelegate {
}