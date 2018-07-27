//
//  GuestViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/25/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"

var guestUsername = [String]() //holds the username for the profile the user is about to view

class GuestViewController: UICollectionViewController {
    
    //for refreshing the page when pulling down
    var toRefresh : UIRefreshControl!
    
    //Determines how many pictures does our app load at one time
    var pageSize : Int = 12
    
    //hold the pictures and the IDS of the cells on screen
    var uuidArray = [String]()
    var pictureArray = [PFFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = .white
        
        //allow the user to scroll downward even if there's not enough images in the view
        //the view bounces back after the user stops scrolling
        self.collectionView?.alwaysBounceVertical = true
        //showing the the last visited username in the navbar
        self.navigationItem.title = guestUsername.last
        
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(GuestViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        //implementing pull to refresh
        toRefresh = UIRefreshControl()
        toRefresh.addTarget(self, action: #selector(GuestViewController.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(toRefresh)
        
        //implementing swipe right to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GuestViewController.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        loadPosts()

    }
    
    
    //MARK: - when back button is pressed, send the user to the previous page visited
    @objc func back(_ sender : UIBarButtonItem) {
        
        // push back
        _ = self.navigationController?.popViewController(animated: true)
        
        // clean guest username or deduct the last guest userame from guestname = Array
        if !guestUsername.isEmpty {
            guestUsername.removeLast()
        }
    }
    
    @objc func refresh() {
        toRefresh.endRefreshing()
        loadPosts()
    }
    
    //MARK: - Load the most up-to-date posts for the profile that the user is currently viewing
    func loadPosts() {
        
        // request infomration from server
        let postsQuery = PFQuery(className: "posts")
        postsQuery.whereKey("username", equalTo: guestUsername.last!) //making sure to get the information for the currently latest visited user
        postsQuery.addDescendingOrder("createdAt") //sorting the posts by the date added in descending order
        postsQuery.limit = pageSize //showing the most recent 12 posts
        
        //method to find and retrieve objects from the database
        postsQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                //Make sure to clean the outdated items before adding the new ones
                self.uuidArray.removeAll(keepingCapacity: false)
                self.pictureArray.removeAll(keepingCapacity: false)
                
                //Append the objects received from the database to our storage arrays
                for object in objects! {
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.pictureArray.append(object.value(forKey: "pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()
                
            } else {
                //IMPORTANT - CAN ADD AN ALERT IF THE REFRESH FAILED
                print(error!.localizedDescription) //unable to update data
            }
        })
        
    }
    
    
    //check whether the user scrolled to the bottom of the page
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            //if the user reached the bottom and there are more posts that are not shown, load the next 12 posts
            loadAdditionalPosts()
            
        }
    }
    
    //loading more posts if necessary.
    //TODO: - unite load additional posts and load posts
    func loadAdditionalPosts() {
        
        //check if there are more posts that arent in the view yet
        if pageSize <= pictureArray.count {
            
            //double the page size
            pageSize = pageSize + 12
            
            // load more posts
            let postsQuery = PFQuery(className: "posts")
            postsQuery.whereKey("username", equalTo: guestUsername.last!)
            postsQuery.addDescendingOrder("createdAt") //sorting the posts by the date added in descending order
            postsQuery.limit = pageSize //limit the query to loading only the size of page number of items
            postsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    //clean up the previous posts shown
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.pictureArray.removeAll(keepingCapacity: false)
                    
                    //
                    for object in objects! {
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.pictureArray.append(object.value(forKey: "pic") as! PFFile)
                    }
                    //refresh the collection view data
                    self.collectionView?.reloadData()
                    
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
        }
    }
    

    //determines how many cells are going to be shown.
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureArray.count
    }
    
    
    //MARK: -  linking the cell class to the guestVC and filling it with data from the pictureArray
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        pictureArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.imageInCell.image = UIImage(data: data!) //placing the image from pictureArray into the cell
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView //making connection to the header view
        
        //MARK: - 1. Retrieve the visited user's data from the Database
        
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: guestUsername.last!) //making sure that we are asking for the most recent user
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                //wrong request. unable to find the user data for the username
                if objects!.isEmpty {
                    self.showAlert(error: "\(guestUsername.last!.uppercased())", message: " does not exist. The user has probably deleted the account.")
                }
                
                //if the user data has been found, place it in the view
                for object in objects! {
                    header.fullNameLabel.text = (object.object(forKey: "FullName") as? String)?.uppercased()
                    header.bioLabel.text = object.object(forKey: "Bio") as? String
                    header.bioLabel.sizeToFit()
                    header.websiteTextField.text = object.object(forKey: "website") as? String
                    header.websiteTextField.sizeToFit()
                    let userAvatar : PFFile = (object.object(forKey: "avatar") as? PFFile)!
                    userAvatar.getDataInBackground(block: { (data, error) -> Void in
                        header.userImage.image = UIImage(data: data!)
                    })
                }
                
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        
        //MARK: - 2. Show if the current user follows the visited user
        
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.whereKey("following", equalTo: guestUsername.last!)
        
        //changing the appearence of the button depending on followQuery
        followQuery.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                if count == 0 {
                    header.profileActionButton.setTitle("Follow", for: UIControlState())
                    header.profileActionButton.backgroundColor = .lightGray
                } else {
                    header.profileActionButton.setTitle("Following", for: UIControlState())
                    header.profileActionButton.backgroundColor = .blue
                }
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        
        
        //MARK: - 3. Count the number of posts, followers, and following
        
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guestUsername.last!)
        posts.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.postsNum.text = "\(count)"
            }
        })
        
        
 
        let followers = PFQuery(className: "follow") 
        followers.whereKey("following", equalTo: guestUsername.last!)
        followers.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followersNum.text = "\(count)"
            }
        })
        
       
        let following = PFQuery(className: "follow")
        following.whereKey("follower", equalTo: guestUsername.last!)
        following.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followingNum.text = "\(count)"
            }
        })
        
        
        //MARK: - 4. Add the ability to tap on posts, followers, and following
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(GuestViewController.postsTap)) //declare gesture recognizer
        postsTap.numberOfTapsRequired = 1 //specifying how many taps to activate
        header.postsNum.isUserInteractionEnabled = true //enabling user interaction
        header.postsNum.addGestureRecognizer(postsTap) //assigning the tap gesture recognizer to the posts number label in the header view
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(GuestViewController.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followersNum.isUserInteractionEnabled = true
        header.followersNum.addGestureRecognizer(followersTap)
        
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(GuestViewController.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followingNum.isUserInteractionEnabled = true
        header.followingNum.addGestureRecognizer(followingsTap)
        
        return header
    }
    
    //MARK: - Methods handling posts, followers and following taps
    
    //when posts are tapped, we down to the bottom, filling the entire screen with posts only
    @objc func postsTap() {
        if !pictureArray.isEmpty {
            let indexToScroll = IndexPath(item: 0, section: 0) //index at the top of the picture grid
            self.collectionView?.scrollToItem(at: indexToScroll, at: UICollectionViewScrollPosition.top, animated: true) //activating the scroll
        }
    }
    
    //shows all of the visited user's followers
    @objc func followersTap() {
        
        user = guestUsername.last! //accessing the global variable 'user' from the FollowersViewController
        showCategory = "followers"
        
        //make a reference to the followersViewController
        let followersVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        
        
        self.navigationController?.pushViewController(followersVC, animated: true)
    }
    
    //shows all the people that are following the visited user
    @objc func followingsTap() {
        
        user = guestUsername.last!
        showCategory = "following"
        //make a reference to the followersViewController
        let followingVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        
        //send the user to the followersViewController
        self.navigationController?.pushViewController(followingVC, animated: true)
    }
    
    //determining the size of a cell. making sure that we can fit 3 cells on every screen.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    //shows an alert with error and message that were passed
    func showAlert(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let alertButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(alertButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}
