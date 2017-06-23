//
//  UIImage+Grayscale.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 24..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit

extension UIImage {
    func grayscale() -> UIImage? {
        guard let context = CGContext.init(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: .allZeros) else { return nil }
        
        guard let inputCGImage = self.cgImage else { return nil}
        
        let imageRect = CGRect(origin: .zero, size: self.size) // (0,0)에 위치한 이미지의 사이즈
        
        context.draw(inputCGImage, in: imageRect)
        
        guard let outputCGImage = context.makeImage() else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
}
