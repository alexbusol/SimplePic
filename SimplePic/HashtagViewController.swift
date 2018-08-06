//
//  HashtagViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 8/6/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

var hashtagArray = [String]()
private let reuseIdentifier = "Cell"

class HashtagViewController: UICollectionViewController {
    
    var toRefresh = UIRefreshControl()
    var pageSize : Int = 24
    
    //storage arrays
    var imageArray = [PFFile]()
    var UUIDArray = [String]()
    var filteredHashtags = [String]() //will store matching hashtags from the DB

    override func viewDidLoad() {
        super.viewDidLoad()

        //allow the user to scroll downward even if there's not enough images in the view
        //the view bounces back after the user stops scrolling
        self.collectionView?.alwaysBounceVertical = true
        
        //display the selected hashtag in the navbar
        self.navigationItem.title = "#" + "\(hashtagArray.last!.uppercased())"
        
        //implementing back button at the top left
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(HashtagViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        //implementing swipe right to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(HashtagViewController.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        //implementing pull to refresh
        toRefresh = UIRefreshControl()
        toRefresh.addTarget(self, action: #selector(HashtagViewController.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(toRefresh)
        
        refresh()

    }
    
    //gets called when the back button or the back swipe is triggered
    @objc func back(_ sender : UIBarButtonItem) {
        
        //show a previous view controller
        _ = self.navigationController?.popViewController(animated: true)
        
        //remove the currently selected hashtag from the storage array
        if !hashtagArray.isEmpty {
            hashtagArray.removeLast()
        }
    }
    
    @objc func refresh() {
        loadHashtagPosts()
    }

    //MARK: - Load the posts that are relevant to the selected hashtag
    func loadHashtagPosts() {
        
        //query the database for the current hashtag to make sure that it exists
        let hashtagQuery = PFQuery(className: "hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtagArray.last!)
        hashtagQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                //make sure the storage array is empty
                self.filteredHashtags.removeAll(keepingCapacity: false)
                
                //store the matching hashtags in the storage array
                for object in objects! {
                    self.filteredHashtags.append(object.value(forKey: "toComment") as! String)
                }
                
                //find the posts that correspond to the current hashtag
                
                let postsQuery = PFQuery(className: "posts")
                postsQuery.whereKey("uuid", containedIn: self.filteredHashtags)
                postsQuery.limit = self.pageSize
                postsQuery.addDescendingOrder("createdAt")
                postsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        //empty the storage arrays from the previous results
                        self.imageArray.removeAll(keepingCapacity: false)
                        self.UUIDArray.removeAll(keepingCapacity: false)
                        
                        //store the results of the query in the storage arrays
                        for object in objects! {
                            self.imageArray.append(object.value(forKey: "pic") as! PFFile)
                            self.UUIDArray.append(object.value(forKey: "uuid") as! String)
                        }
                        
                        //reload the collection view to show new data
                        self.collectionView?.reloadData()
                        self.toRefresh.endRefreshing()
                        
                    } else {
                        print(error?.localizedDescription ?? String())
                    }
                })
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
    }
    

    //MARK: - If the user scrolled to the bottom and there are more related posts to display, load more posts
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 3 {
            loadMorePosts()
        }
    }

    func loadMorePosts() {
        
        //check if there are more related posts than currently shown
        if pageSize <= UUIDArray.count {
            
            pageSize = pageSize + 15
            
            //repeat the same loading process
            loadHashtagPosts()
          
        }
        
    }

    //MARK: - Fill the HashtagView with the data related to the current hashtag
    //specify the number of cells in collection view
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return cellSize
    }
    
    
    //dequeue a cell and place an image from the imageArray into it
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell

        imageArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.imageInCell.image = UIImage(data: data!)
            }
        }
    
        return cell
    }
    
    
    //open one of the posts in the Hashtag  View
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // send post uuid to "postuuid" variable
        postToLoadUUID.append(UUIDArray[indexPath.row])
        
        // navigate to post view controller
        let goToPost = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        self.navigationController?.pushViewController(goToPost, animated: true)
    }

}
