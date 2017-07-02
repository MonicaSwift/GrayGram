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
    enum ViewMode {
        case card
        case tile
    }
    fileprivate var posts:[Post] = []
    fileprivate var nextURLString:String?
    fileprivate var isLoading:Bool = false
    fileprivate var viewMode:ViewMode = .card {
        didSet {
            switch self.viewMode {
            case .card:
                self.navigationItem.leftBarButtonItem = self.tileButtonItem
            case .tile:
                self.navigationItem.leftBarButtonItem = self.cardButtonItem
            }
            self.collectionView.reloadData()
        }
    }
    
    fileprivate let tileButtonItem = UIBarButtonItem(image: UIImage(named:"icon-tile"), style: .plain, target: nil, action: nil)
    fileprivate let cardButtonItem = UIBarButtonItem(image: UIImage(named:"icon-card"), style: .plain, target: nil, action: nil)
    fileprivate let refreshControl = UIRefreshControl()
    
    fileprivate let collectionView = UICollectionView(
        frame : CGRect.zero,
        collectionViewLayout : UICollectionViewFlowLayout()
    )
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.navigationItem.title = "Graygram"
        self.tabBarItem.title = "Feed"
        self.tabBarItem.image = UIImage(named: "tab-feed")
        self.tabBarItem.selectedImage = UIImage(named: "tab-free-selected")
        
        self.tileButtonItem.target = self
        self.tileButtonItem.action = #selector(tileButtonItemDidTap)
        self.cardButtonItem.target = self
        self.cardButtonItem.action = #selector(cardButtonItemDidTap)
        self.navigationItem.leftBarButtonItem = self.tileButtonItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(PostCardCell.self, forCellWithReuseIdentifier: "cardCell")
        collectionView.register(PostTileCell.self, forCellWithReuseIdentifier: "tileCell")
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
       
        NotificationCenter.default.addObserver(self, selector: #selector(postDidLike), name: .postDidLike, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postDidUnlike), name: .postDidUnlike, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postDidCreate), name: .postDidCreate, object: nil)
        
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
            urlString = "https://api.graygram.com/feed"
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

    // MARK : Notification
    
    func postDidLike(notification:Notification) {
        print("postDidLike")
        guard let postID = notification.userInfo?["postID"] as? Int else { return }
        
        // 방법1.
//        self.posts = self.posts.map { post in
//            if post.id == postID {
//                var newPost = post
//                newPost.isLiked = true
//                newPost.likeCount! += 1
//                return newPost
//            } else {
//                return post
//            }
//            
//        }
        
        // 방법2.
//        guard let index = self.posts.index(where: { (post:Post) -> Bool in
//            return post.id == postID
//        })
//        else {return}
        
        // 방법3.
        guard let index = self.posts.index(where: {$0.id == postID} ) else {return}
        
        var newPost = posts[index]
        newPost.isLiked = true
        newPost.likeCount! += 1
        posts[index] = newPost
        
        //print("\(posts[0].isLiked):\(posts[0].likeCount)") //첫번때 포스트로 테스트
    }
    
    func postDidUnlike(notification:Notification) {
        print("postDidUnlike")
        
        guard let postID = notification.userInfo?["postID"] as? Int else { return }
        guard let index = self.posts.index(where: {$0.id == postID} ) else {return}
        var newPost = posts[index]
        newPost.isLiked = false
        newPost.likeCount! -= 1
        posts[index] = newPost

        //print("\(posts[0].isLiked):\(posts[0].likeCount)") //첫번때 포스트로 테스트
    }
    
    func postDidCreate(notification:Notification) {
        guard let post = notification.userInfo?["post"] as? Post else { return }
        self.posts.insert(post, at: 0)
        self.collectionView.reloadData()
    }
    
    func tileButtonItemDidTap() {
        self.viewMode = .tile
    }
    
    func cardButtonItemDidTap() {
        self.viewMode = .card
    }
}

extension FeedViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.viewMode {
        case .card:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath) as! PostCardCell
            let post = self.posts[indexPath.item]
            cell.configure(post: post)
            return cell
        case .tile:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tileCell", for: indexPath) as! PostTileCell
            let post = self.posts[indexPath.item]
            cell.configure(post: post)
            cell.didTap = {
                let viewController = PostViewController(postID: post.id)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            return cell
        }
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
        switch self.viewMode {
        case .card:
            return PostCardCell.size(width: collectionView.frame.size.width, post: post)
        case .tile:
            return PostTileCell.size(width: collectionView.width/3)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y, scrollView.height, scrollView.contentSize.height, scrollView.bounds.origin.y)
        guard scrollView.contentSize.height > 0 else { return }
        
        let contentOffsetBottom = scrollView.contentOffset.y + scrollView.height
        if contentOffsetBottom >= scrollView.contentSize.height - 300 {
            //print("load more")
            fetchPosts(isMore: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch self.viewMode {
        case .card:
            return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        default:
            return UIEdgeInsets.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch self.viewMode {
        case .card:
            return 20
        case .tile:
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

