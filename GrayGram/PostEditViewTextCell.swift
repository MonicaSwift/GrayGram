//
//  PostEditViewTextCell.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 27..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit

final class PostEditViewTextCell:UITableViewCell{
    fileprivate enum Font {
        static let textView = UIFont.systemFont(ofSize: 14)
    }
    fileprivate let textView = UITextView()
    var textDidChange:((String?) -> Void)?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textView.font = Font.textView
        self.textView.delegate = self
        self.textView.isScrollEnabled = false
        self.contentView.addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text:String?) {
        self.textView.text = text
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textView.width =  self.contentView.width
        self.textView.height = self.contentView.height
    }

    class func height(width:CGFloat, text:String?) -> CGFloat {
        let margin = CGFloat(10)
        let minimumHeight = ceil(Font.textView.lineHeight) * 3
        guard let text = text else { return minimumHeight + margin * 2 }
        return max(text.size(width: width, font: Font.textView).height, minimumHeight + margin * 2)
    }
}

extension PostEditViewTextCell:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.textDidChange?(textView.text)
    }
}
