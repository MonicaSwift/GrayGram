//
//  UIImageView+Photo.swift
//  GrayGram
//
//  Created by me on 2017. 6. 12..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit

enum PhotoSize {
  case tiny
  case small
  case medium
  case large
  
  var pointSize: Int { // 1x 기준.
    switch self {
    case .tiny: return 20
    case .small: return 40
    case .medium: return 320
    case .large: return 640
    }
  }
  
  var pixelSize: Int {
    return self.pointSize * Int(UIScreen.main.scale)
  }
}

extension UIImageView {
//  func setImage(photoID:String, size:Int) {
//  let urlString = "https://www.graygram.com/photos/\(photoID)/\(size)x\(size)"
  //enum 설정 후
  //func setImage(photoID:String, size:PhotoSize) {
  func setImage(photoID:String?, size:PhotoSize) {
    guard let photoID = photoID else {
      self.image = nil
      return
    }
    let pixel = size.pixelSize
    let urlString = "https://www.graygram.com/photos/\(photoID)/\(pixel)x\(pixel)"
    let url = URL(string: urlString)!
    self.kf.setImage(with: url)

  }
  
}
