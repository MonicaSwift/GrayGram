//
//  PostEditViewController.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 27..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit
import Alamofire

final class PostEditViewController:UIViewController {
    fileprivate let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    fileprivate let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    fileprivate let progressView = UIProgressView()
    fileprivate let tableView = UITableView(frame:.zero, style:.grouped)
    
    fileprivate let image:UIImage
    fileprivate var text:String? 
    
    init(image:UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        
        self.cancelButtonItem.target = self
        self.cancelButtonItem.action = #selector(cancelButtonItemDidTap)
        self.navigationItem.leftBarButtonItem = self.cancelButtonItem
        self.doneButtonItem.target = self
        self.doneButtonItem.action = #selector(doneButtonItemDidTap)
        self.navigationItem.rightBarButtonItem = self.doneButtonItem

        
        self.progressView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        self.view.addSubview(tableView)
        self.view.addSubview(progressView)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.progressView.snp.makeConstraints { make in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.register(PostEditViewImageCell.self, forCellReuseIdentifier: "imageCell")
        self.tableView.register(PostEditViewTextCell.self, forCellReuseIdentifier: "textCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    func keyboardWillChangeFrame(notification:Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        let keyboardVisibleHeight = UIScreen.main.bounds.height - keyboardFrame.y
        UIView.animate(withDuration: duration) {
            self.tableView.contentInset.bottom = keyboardVisibleHeight
            self.tableView.scrollIndicatorInsets.bottom = keyboardVisibleHeight
            let isShowing = keyboardVisibleHeight > 0
            if isShowing {
                self.tableView.scrollToRow(at: IndexPath(row:1, section:0), at: .none, animated: false)
            }
        }
    }
    
    func cancelButtonItemDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonItemDidTap() {
        self.setControlIsEnabled(false)
        self.progressView.isHidden = false
        
        let urlString = "https://api.graygram.com/posts"
        Alamofire.upload(
            multipartFormData: { formData in
                if let imageData = UIImageJPEGRepresentation(self.image, 1) {
                    formData.append(imageData, withName: "photo", fileName: "photo", mimeType: "image/jpeg")
                }
                if let textData = self.text?.data(using: .utf8){
                    formData.append(textData, withName: "message")
                }
            },
            to: urlString,
            method: .post,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let request, _, _):
                    print("인코딩 성공 \(request)")
                    request
                        .uploadProgress(closure: { (progress) in
                            self.progressView.progress = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                        })
                        .validate(statusCode: 200 ..< 400)
                        .responseJSON(completionHandler: { response in
                            switch response.result {
                            case .success(let value):
                                print("업로드 성공 \(value)")
                                if let json = value as? [String:Any], let post = Post(JSON: json){
                                    NotificationCenter.default.post(name: .postDidCreate, object: self, userInfo: ["post":post])
                                }
                                self.dismiss(animated: true, completion: nil)
                            case .failure(let error):
                                print("업로드 실패 \(error)")
                                self.setControlIsEnabled(true)
                                self.progressView.isHidden = true
                            }
                        })
                case .failure(let error):
                    print("인코딩 실패 \(error)")
                    self.setControlIsEnabled(true)
                    self.progressView.isHidden = true
                }
            }
        )
    }
    
    func setControlIsEnabled(_ isEnabled:Bool) {
        self.cancelButtonItem.isEnabled = isEnabled
        self.doneButtonItem.isEnabled = isEnabled
        self.view.isUserInteractionEnabled = isEnabled
    }
}

extension PostEditViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return PostEditViewImageCell.height(width: tableView.width)
        } else {
            return PostEditViewTextCell.height(width: tableView.width, text:self.text)
        }
    }
}

extension PostEditViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! PostEditViewImageCell
            cell.configure(image: self.image)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! PostEditViewTextCell
            cell.configure(text: self.text)
            cell.textDidChange = { text in
                self.text = text
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                self.tableView.scrollToRow(at: IndexPath(row:1, section:0), at: .none, animated: true)
            }
            return cell
        }
    }
}
