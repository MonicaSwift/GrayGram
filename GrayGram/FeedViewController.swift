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
  fileprivate var nextURLString: String?
  fileprivate var isLoading: Bool = false
  
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
    // 최초에 한번만 불리므로 변화에 대응을 못함. 여기에서 크기를 지정하는 것은 좋지않음. 가로로 돌렸다던지..->autolayout
    collectionView.frame = self.view.frame
    
    refreshControl.addTarget(self, action: #selector(refreshControlDidChangeValue), for: UIControlEvents.valueChanged)
    
    self.view.addSubview(collectionView)
    
    collectionView.addSubview(refreshControl)
    
    fetchPosts()
  }
  
  func refreshControlDidChangeValue() {
    fetchPosts()
  }
  
  fileprivate func fetchPosts(isMore: Bool = false) {
//    let num:Int
//    if true {
//      num = 10
//    } else {
//      num = 0
//    }
    guard !isLoading else { return }
    
    let urlString: String
    if !isMore {
      urlString = "https://api.graygram.com/feed?limit=3"
    } else if let nextURLString = self.nextURLString {
      urlString = nextURLString
    } else {
      return
    }
    //print(urlString)
    
    isLoading = true
    
    //Alamofire.request("https://api.graygram.com/feed")
    //Alamofire.request("https://api.graygram.com/feed?limit=3")
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
            self.posts += newPosts!
            //self.posts.append(contentsOf: newPosts)
          }
          
          let paging = json["paging"] as? [String:Any]
          self.nextURLString = paging?["next"] as? String //footer 마지막 로딩 테스트 시 주석처리
          
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
    //cell.backgroundColor = .gray
    let post = self.posts[indexPath.item]
    cell.configure(post: post)
    return cell
  }
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                    withReuseIdentifier: "activityIndicatorView",
                                                    for: indexPath)
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    if self.nextURLString == nil, !self.posts.isEmpty {
      return .zero
    } else {
      return CGSize(width: collectionView.width, height: 44)
    }
    
    
  }
}

extension FeedViewController:UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let post = self.posts[indexPath.item]
    return PostCardCell.size(width: collectionView.frame.size.width, post: post)
    //return CGSize(width:collectionView.frame.size.width, height:collectionView.frame.size.width)
  }
  //스크롤될때마다 호출되므로 가벼워야함
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // UIScrollViewDelegate에 구현되어있음 
    //print(scrollView.contentOffset.y, scrollView.contentSize.height )
    //print(scrollView.contentOffset.y + scrollView.height, scrollView.contentSize.height )
    guard scrollView.contentSize.height > 0 else { return }
    
    let contentOffestBottom = scrollView.contentOffset.y + scrollView.height
    if contentOffestBottom >= scrollView.contentSize.height - 300 {
      //print("Load more...")
      fetchPosts(isMore: true)
    }
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    // UIEdgeInsets는 top / left / bottom / right 가짐
    return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
  }
  
  // 상하간격 조정 linespacing
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 20
  }
}

