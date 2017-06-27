//
//  PostEditViewController.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 27..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit

final class PostEditViewController:UIViewController {
    fileprivate let tableView = UITableView(frame:.zero, style:.grouped)
    
    fileprivate let image:UIImage
    fileprivate var text:String? 
    
    init(image:UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.register(PostEditViewImageCell.self, forCellReuseIdentifier: "imageCell")
        self.tableView.register(PostEditViewTextCell.self, forCellReuseIdentifier: "textCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        self.view.addSubview(tableView)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
