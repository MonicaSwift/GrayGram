//
//  CropViewController.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 23..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit

final class CropViewController:UIViewController {
    
    var didFinichCropping: ((UIImage) -> Void)?
    
    fileprivate let scrollView = UIScrollView()
    fileprivate let imageView = UIImageView()
    // 가이드 뷰
    fileprivate let cropAreaView = UIView()
    // 커버 뷰
    fileprivate let topCoverView = UIView()
    fileprivate let bottomCoverView = UIView()
    
    init(image:UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
        
        self.cropAreaView.layer.borderColor = UIColor.lightGray.cgColor
        self.cropAreaView.layer.borderWidth = 1 / UIScreen.main.scale
        
        self.topCoverView.backgroundColor = .white
        self.topCoverView.alpha = 0.9
        self.bottomCoverView.backgroundColor = .white
        self.bottomCoverView.alpha = 0.9
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonItemDidTap))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonItemDidTap))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.alwaysBounceHorizontal = true
        
        self.scrollView.maximumZoomScale = 3
        self.scrollView.minimumZoomScale = 0.5
        self.scrollView.delegate = self
        
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.topCoverView.isUserInteractionEnabled = false
        self.bottomCoverView.isUserInteractionEnabled = false
        self.cropAreaView.isUserInteractionEnabled = false
        
        self.scrollView.addSubview(self.imageView)
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.topCoverView)
        self.view.addSubview(self.bottomCoverView)
        self.view.addSubview(self.cropAreaView)
        
        self.scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        self.cropAreaView.snp.makeConstraints{ make in
            make.width.equalToSuperview()
            make.height.equalTo(self.cropAreaView.snp.width)
            make.centerY.equalToSuperview()
        }
        self.topCoverView.snp.makeConstraints{ make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.cropAreaView.snp.top)
        }
        self.bottomCoverView.snp.makeConstraints{ make in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(self.cropAreaView.snp.bottom)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.imageView.size == .zero {
            self.imageView.size = self.scrollView.size
        }
        self.initializeContentSize()
    }
    
    private func initializeContentSize() {
        guard let image = self.imageView.image else { return }
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        if imageWidth > imageHeight { // landscape
            self.imageView.height = self.cropAreaView.height
            self.imageView.width = imageWidth * self.cropAreaView.height / imageHeight
        } else if imageWidth < imageHeight { // portrait
            self.imageView.width = self.cropAreaView.width
            self.imageView.height = imageHeight * self.cropAreaView.width / imageWidth
        } else { //정사각형
            self.imageView.size = self.cropAreaView.size
        }
        self.scrollView.contentInset.top = (self.scrollView.height -  self.cropAreaView.height) / 2
        self.scrollView.contentInset.bottom = self.scrollView.contentInset.top
        self.scrollView.contentSize = self.imageView.size
        self.centerContent()
    }

    private func centerContent() {
        self.scrollView.contentOffset.x = (self.scrollView.contentSize.width - self.scrollView.width) / 2
        self.scrollView.contentOffset.y = (self.scrollView.contentSize.height - self.scrollView.height) / 2
    }
    
    func cancelButtonItemDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonItemDidTap() {
        guard let image = self.imageView.image else { return }
        
        var rect = self.scrollView.convert(self.cropAreaView.frame, from: self.cropAreaView.superview)
        rect.origin.x *= image.size.width / self.imageView.width
        rect.origin.y *= image.size.height / self.imageView.height
        rect.size.width *= image.size.width / self.imageView.width
        rect.size.height *= image.size.height / self.imageView.height
        
        if let croppedCGImage = image.cgImage?.cropping(to: rect) {
            let croppedImage = UIImage(cgImage: croppedCGImage)
            self.didFinichCropping?(croppedImage)
        }
    }
}

extension CropViewController:UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
