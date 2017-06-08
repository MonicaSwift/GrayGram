//
//  String+Size.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 8..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit
extension String {
    func size(width: CGFloat, font: UIFont, numberOfLines: Int = 0) -> CGSize {
        let maximumHeight = numberOfLines == 0
            ? CGFloat.greatestFiniteMagnitude
            : font.lineHeight * CGFloat(numberOfLines)
        let constraintSize = CGSize(width: width, height: maximumHeight)
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let attributes: [String: Any] = [NSFontAttributeName: font]
        let boundingRect = self.boundingRect(
            with: constraintSize,
            options: options,
            attributes: attributes,
            context: nil
        )
        return CGSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
    }
}

