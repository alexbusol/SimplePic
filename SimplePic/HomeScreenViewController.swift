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
        //allow the user to scroll downward even if there's not enough images in the view
        //the view bounces back after the user stops scrolling
        self.collectionView?.alwaysBounceVertical = true
        //showing the current user's username in the navbar
        self.navigationItem.title = PFUser.current()?.username?.uppercased()
        
        //implementing pull to refresh
        toRefresh = UIRefreshControl()
        toRefresh.addTarget(self, action: #selector(HomeScreenViewController.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(toRefresh)
    
       
        //receiving notification from post view controller after post deletion
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreenViewController.updateCollectionView), name: NSNotification.Name(rawValue: "deletedPost"), object: nil)
        
        //load the posts when open the homescreen
        loadPosts()
        
    }
    
    
    //MARK: - Making sure that all the date is up-to-date every time the user sees HomeViewController
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView?.reloadData()
    }
    
    @objc func refresh() {
        loadPosts()
        
        toRefresh.endRefreshing() //stops refreshing animation when the new data was received
    }
    
    //refreshing the user posts after a new one has been added
    @objc func updateCollectionView() {
        loadPosts()
    }

    //MARK: - Load the most up-to-date posts for the user profile
    func loadPosts() {
        
        // request infomration from server
        let postsQuery = PFQuery(className: "posts")
        postsQuery.whereKey("username", equalTo: PFUser.current()!.username!) //making sure to get the information for the currently logged-in user
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
            postsQuery.whereKey("username", equalTo: PFUser.current()!.username!)
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
            //setting the default "add avatar" image if the user didnt upload an avatar during signup
            header.userImage.image = #imageLiteral(resourceName: "addAv")
            //making sure convert the default avatar to JPEG and send it to the server
            let currentUser = PFUser.current()
            let avatar = UIImageJPEGRepresentation(header.userImage.image!, 0.5)
            let avatarToSend = PFFile(name: "Avatar.jpg", data: avatar!)
            currentUser!["avatar"] = avatarToSend
            
            //saving our changes using Parse's saveInBackgound method
            currentUser?.saveInBackground(block: { (success, error) in
                if success {
                    print("avatar updated to default image")
                } else {
                    print("Failed to update the avatar. \(error?.localizedDescription)")
                }
            })
        }
        
        header.profileActionButton.setTitle("Edit Profile", for: UIControlState())
        
        
        //MARK: - 2. Count the number of posts, followers, and following
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.current()!.username!)
        posts.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.postsNum.text = "\(count)"
            }
        })
        
        
       
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: PFUser.current()!.username!)
        followers.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followersNum.text = "\(count)"
            }
        })

        
        
        let following = PFQuery(className: "follow") 
        following.whereKey("follower", equalTo: PFUser.current()!.username!)
        following.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followingNum.text = "\(count)"
            }
        })
        
        
        //MARK: - 3. Add the ability to tap on posts, followers, and following
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(HomeScreenViewController.postsTap)) //declare gesture recognizer
        postsTap.numberOfTapsRequired = 1 //specifying how many taps to activate
        header.postsNum.isUserInteractionEnabled = true //enabling user interaction
        header.postsNum.addGestureRecognizer(postsTap) //assigning the tap gesture recognizer to the posts number label in the header view
      
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(HomeScreenViewController.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followersNum.isUserInteractionEnabled = true
        header.followersNum.addGestureRecognizer(followersTap)
        
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(HomeScreenViewController.followingsTap))
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
    
    //shows all user's followers
    @objc func followersTap() {
        
        user = PFUser.current()!.username! //accessing the global variable 'user' from the FollowersViewController
        showCategory = "followers"
        
        //make a reference to the followersViewController
        let followersVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        
  
        self.navigationController?.pushViewController(followersVC, animated: true)
    }
    
    //shows all the people following the user
    @objc func followingsTap() {
        
        user = PFUser.current()!.username!
        showCategory = "following"
        //make a reference to the followersViewController
        let followingVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        
        //send the user to the followersViewController
        self.navigationController?.pushViewController(followingVC, animated: true)
    }
    
    //MARK: - Logout the user
    @IBAction func logout_pressed(_ sender: UIBarButtonItem) {
        PFUser.logOutInBackground { (error) in
            if error == nil {
                print("logout successful")
                //deleting the user's login from the user defaults
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.synchronize()
                
                //redirecting the user to the SignInViewController
                let signInVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = signInVC
            } else {
                self.showAlert(title: "Logout failed", message: "There was an error logging out. \(error?.localizedDescription)")
            }
        }
    }
    
    //shows an alert with error and message that were passed
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(alertButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Open to a certain post
    //this method gets called when a user selects an image from the collection view in Home/Guest Views
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //pass the UUID of the post that the user selected to the PostViewController
        postToLoadUUID.append(uuidArray[indexPath.row])
        
        //navigate to the PostViewController
        let postToOpen = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        self.navigationController?.pushViewController(postToOpen, animated: true)
        
        
    }
    
}


//making sure the screen can fit 3x3 matrix of images
extension HomeScreenViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width/3, height: self.view.frame.size.width/3)
    }
    
}
