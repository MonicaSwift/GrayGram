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
    
    fileprivate let collectionView = UICollectionView(
        frame : CGRect.zero,
        collectionViewLayout : UICollectionViewFlowLayout()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(PostCardCell.self, forCellWithReuseIdentifier: "cardCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.frame = self.view.frame
        self.view.addSubview(collectionView)
        fetchPosts()
    }
    
    fileprivate func fetchPosts() {
        Alamofire.request("https://api.graygram.com/feed")
            .responseJSON { response in
                switch response.result {
                case .success(let value) :
                    //print(value)
                    guard let json = value as? [String:Any] else {return}
                    guard let jsonArray = json["data"] as? [[String:Any]] else {return}
                    let newPosts = [Post](JSONArray: jsonArray)
                    // print(newPosts)
                    self.posts = newPosts!
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
        cell.backgroundColor = .gray
        let post = self.posts[indexPath.item]
        cell.configure(post: post)
        return cell
    }
}

extension FeedViewController:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = self.posts[indexPath.item]
        return PostCardCell.size(width: collectionView.frame.size.width, post: post)
        //return CGSize(width:collectionView.frame.size.width, height:collectionView.frame.size.width)
    }
}

