//
//  HomeScreenViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/24/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"

class HomeScreenViewController: UICollectionViewController {
    
    //for refreshing the page when pulling down
    var toRefresh : UIRefreshControl!
    
    //Determines how many pictures does our app load at one time
    var pageSize : Int = 12
    
    //hold the pictures and the IDS of the cells on screen
    var uuidArray = [String]()
    var pictureArray = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = PFUser.current()?.username?.uppercased() //showing the current user's username in the navbar
        
        //implementing pull to refresh
        toRefresh = UIRefreshControl()
        toRefresh.addTarget(self, action: #selector(HomeScreenViewController.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(toRefresh)
    
        //load the posts when open the homescreen
        loadPosts()
        
    }
    
    @objc func refresh() {
        loadPosts()
        
        toRefresh.endRefreshing() //stops refreshing animation when the new data was received
    }

    //MARK: - Load the most up-to-date posts for the user profile
    func loadPosts() {
        
        // request infomration from server
        let postsQuery = PFQuery(className: "posts")
        postsQuery.whereKey("username", equalTo: PFUser.current()!.username!) //making sure to get the information for the currently logged-in user
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

    //determines how many cells are going to be shown.
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureArray.count
    }
    
    //MARK: -  linking the cell class to the homescreenVC and filling it with data from the pictureArray
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
        
        //MARK: - 1. Populate user's profile with info from the database
        //retrieving each of the column's info using the column key
        header.fullNameLabel.text = (PFUser.current()?.object(forKey: "FullName") as? String)?.uppercased() //getting current user's full name from the database
        
        header.websiteTextField.text = PFUser.current()?.object(forKey: "website") as? String
        header.websiteTextField.sizeToFit()
        header.bioLabel.text = PFUser.current()?.object(forKey: "Bio") as? String
        header.bioLabel.sizeToFit() //making sure that the textview size matches the website length
        
        //preventing crash if the avatar is empty
        if let currentAvatar = PFUser.current()?.object(forKey: "avatar") as? PFFile {
            currentAvatar.getDataInBackground { (data, error) -> Void in
                if (error == nil) {
                    header.userImage.image = UIImage(data: data!)
                } else {
                    print("unable to get avatar \(error)")
                }
            }
        } else {
            print("avatar is empty")
            header.userImage.image = #imageLiteral(resourceName: "addAv") //setting the default "add avatar" image if the user didnt upload an avatar during signup
        }
        
        header.profileActionButton.setTitle("Edit Profile", for: UIControlState())
        
        
        //MARK: - 2. Count the number of posts, followers, and following
        //creating a new class named posts in the database
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.current()!.username!)
        posts.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.postsNum.text = "\(count)"
            }
        })
        
        
        //creating a new class named followers in the database
        let followers = PFQuery(className: "follow") //creating a new class named posts in the database
        followers.whereKey("following", equalTo: PFUser.current()!.username!)
        followers.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followersNum.text = "\(count)"
            }
        })
        
        //creating a new class named following in the database
        let following = PFQuery(className: "follow") //creating a new class named posts in the database
        following.whereKey("follower", equalTo: PFUser.current()!.username!)
        following.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followingNum.text = "\(count)"
            }
        })
        return header
    }
/*
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
*/
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
