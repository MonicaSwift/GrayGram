//
//  FeedViewController.swift
//  GrayGram
//
//  Created by celia me on 2017. 6. 7..
//  Copyright © 2017년 celia me. All rights reserved.
//

import UIKit
import Alamofire

final class FeedViewController: UIViewController {
    fileprivate var posts:[Post] = []
    fileprivate var nextURLString:String?
    fileprivate var isLoading:Bool = false
    fileprivate let refreshControl = UIRefreshControl()
    
    fileprivate let collectionView = UICollectionView(
        frame : CGRect.zero,
        collectionViewLayout : UICollectionViewFlowLayout()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(PostCardCell.self, forCellWithReuseIdentifier: "cardCell")
        collectionView.register(CollectionActivityIndicatorView.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: "activityIndicatorView")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(resfreshControlDidChangeValue), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        self.view.addSubview(collectionView)
        
        //collectionView.frame = self.view.frame
        collectionView.snp.makeConstraints{ make in
            //make.top.equalTo(self.view).offset(100)
            //make.top.left.bottom.right.equalToSuperview()
            make.edges.equalToSuperview()
        }
       
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func resfreshControlDidChangeValue() {
        fetchPosts()
    }
    
    fileprivate func fetchPosts(isMore:Bool = false) {
        
        guard !isLoading else { return }
        
        let urlString:String
        if !isMore {
            urlString = "https://api.graygram.com/feed?limit=3"
        } else if let nextURLString = self.nextURLString {
            urlString = nextURLString
        } else {
            return
        }
        isLoading = true
        
        Alamofire.request(urlString)
            .responseJSON { response in
                self.isLoading = false
                self.refreshControl.endRefreshing()
                switch response.result {
                case .success(let value) :
                    //print(value)
                    guard let json = value as? [String:Any] else {return}
                    guard let jsonArray = json["data"] as? [[String:Any]] else {return}
                    let newPosts = [Post](JSONArray: jsonArray)
                    // print(newPosts)
                    
                    if !isMore {
                        self.posts = newPosts!
                    } else {
                        //self.posts += newPosts!
                        self.posts.append(contentsOf: newPosts!)
                    }
                    
                    let paging = json["paging"] as? [String:Any]
                    self.nextURLString = paging?["next"] as? String
                    
                    self.collectionView.reloadData()
                case .failure(let error) :
                    print(error)
                }
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension FeedViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath) as! PostCardCell
        let post = self.posts[indexPath.item]
        cell.configure(post: post)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                               withReuseIdentifier: "activityIndicatorView", for: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.nextURLString == nil, !self.posts.isEmpty {
            return .zero
        } else {
            return CGSize(width: collectionView.width, height:44)
        }
    }
}

extension FeedViewController:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = self.posts[indexPath.item]
        return PostCardCell.size(width: collectionView.frame.size.width, post: post)
        //return CGSize(width:collectionView.frame.size.width, height:collectionView.frame.size.width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y, scrollView.height, scrollView.contentSize.height)
        guard scrollView.contentSize.height > 0 else { return }
        
        let contentOffsetBottom = scrollView.contentOffset.y + scrollView.height
        if contentOffsetBottom >= scrollView.contentSize.height - 300 {
            //print("load more")
            fetchPosts(isMore: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

