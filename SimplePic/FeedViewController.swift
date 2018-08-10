//
//  FeedViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 8/10/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UITableViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var toRefresh = UIRefreshControl()
    
    //storage arrays for data received from the Database
    var usernameArray = [String]()
    var avatarArray = [PFFile]()
    var postDateArray = [Date?]()
    var postImageArray = [PFFile]()
    var postDescriptionArray = [String]()
    var UUIDArray = [String]()
    
    var followingArray = [String]()
    
    var pageSize : Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Your feed"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        //implementing 'pull to refresh'
        toRefresh.addTarget(self, action: #selector(FeedViewController.loadPosts), for: UIControlEvents.valueChanged)
        tableView.addSubview(toRefresh)
        
        //receiving notification from UploadViewController
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.updateTableView), name: NSNotification.Name(rawValue: "uploadedPost"), object: nil)
        
        //receive notification from Post Cell when picture is liked
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        //placing the indicator in the center horizontally
        indicator.center.x = tableView.center.x
        
        loadPosts()
    }
    
    @objc func refresh() {
        tableView.reloadData()
    }

    @objc func updateTableView(_ notification:Notification) {
        loadPosts()
    }
    
    //MARK: - Load the posts of the people who the user is following
    @objc func loadPosts() {
        
        //query the database for the current user's followings
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                //make sure the storage arrays are empty
                self.followingArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.followingArray.append(object.object(forKey: "following") as! String)
                }
                
                //include the current user in the following array to display the user's post in the feed
                self.followingArray.append(PFUser.current()!.username!)
                
                //query the database for the posts
                let postsQuery = PFQuery(className: "posts")
                postsQuery.whereKey("username", containedIn: self.followingArray)
                postsQuery.limit = self.pageSize
                postsQuery.addDescendingOrder("createdAt")
                postsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        //make sure the storage arrays are empty
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avatarArray.removeAll(keepingCapacity: false)
                        self.postDateArray.removeAll(keepingCapacity: false)
                        self.postImageArray.removeAll(keepingCapacity: false)
                        self.postDescriptionArray.removeAll(keepingCapacity: false)
                        self.UUIDArray.removeAll(keepingCapacity: false)
                        
                        //place the query results into the storage arrays
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avatarArray.append(object.object(forKey: "avatar") as! PFFile)
                            self.postDateArray.append(object.createdAt)
                            self.postImageArray.append(object.object(forKey: "pic") as! PFFile)
                            self.postDescriptionArray.append(object.object(forKey: "title") as! String)
                            self.UUIDArray.append(object.object(forKey: "uuid") as! String)
                        }
                        
                        //reload the table view and end the refreshing animation
                        self.tableView.reloadData()
                        self.toRefresh.endRefreshing()
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    //user scrolled to the bottom of the table View and there are more posts left to display
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            loadAdditionalPosts()
        }
    }
    
    func loadAdditionalPosts() {
        if pageSize <= UUIDArray.count {
            
            //start the loading animation
            indicator.startAnimating()
            
            //increase the page size
            pageSize = pageSize + 10
            
            
            loadPosts()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UUIDArray.count
    }
    
    //MARK: - Reusing the 'PostCell' for the Feed, as well as most of the functionality from the PostViewController
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //define a tableViewCell
        let postCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        //place the data from the storage arrays into the cell
        postCell.usernameButton.setTitle(usernameArray[indexPath.row], for: .normal) //changing the title of the username button to the post creator's username
        postCell.uuidLabel.text = UUIDArray[indexPath.row]
        postCell.descriptionLabel.text = postDescriptionArray[indexPath.row]
        postCell.descriptionLabel.sizeToFit()
        
        avatarArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil {
                postCell.userAvatar.image = UIImage(data: data!)
            }
        }
        postImageArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil {
                postCell.postImage.image = UIImage(data: data!)
            }
        }
        
        //MARK: - Displaying when was the post created
        let dateReceived = postDateArray[indexPath.row]
        let currentDate = Date() //getting the current date
        
        //defining time compontents that will be used in the post date label
        let timeComponents : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        //calculating time difference between the current date and the post date
        let timeDifference = (Calendar.current as NSCalendar).components(timeComponents, from: dateReceived!, to: currentDate, options: [])
        
        //if there's no difference between current date and post date
        if timeDifference.second! <= 0 {
            postCell.postDateLabel.text = "Just now"
        }
        //if the time difference is less than 1 minute
        if timeDifference.second! > 0 && timeDifference.minute! == 0 {
            postCell.postDateLabel.text = "\(String(describing: timeDifference.second!))s ago" //display the difference in seconds
        }
        //if the time difference is less than 1 hour
        if timeDifference.minute! > 0 && timeDifference.hour! == 0 {
            postCell.postDateLabel.text = "\(String(describing: timeDifference.minute!))m ago" //display the difference in minutes
        }
        //if the time difference is less than 1 day
        if timeDifference.hour! > 0 && timeDifference.day! == 0 {
            postCell.postDateLabel.text = "\(String(describing: timeDifference.hour!))h ago" //display the difference in hours
        }
        //if the time difference is less than 1 week
        if timeDifference.day! > 0 && timeDifference.weekOfMonth! == 0 {
            postCell.postDateLabel.text = "\(String(describing: timeDifference.day!))d ago" //display the difference in days
        }
        //if the time difference is more than 1 week
        if timeDifference.weekOfMonth! > 0 {
            postCell.postDateLabel.text = "\(String(describing: timeDifference.weekOfMonth!))w ago" //display the difference in weeks
        }
        
        
        //MARK: - Implementing 'like button' functionality
        //changing the like button image depending whether the user liked the post
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("likedBy", equalTo: PFUser.current()!.username!)
        didLike.whereKey("likeTo", equalTo: postCell.uuidLabel.text!)
        didLike.countObjectsInBackground { (count, error) -> Void in
            //if no likes are found
            if count == 0 {
                //change the title and the background image
                postCell.likeButton.setTitle("unliked", for: UIControlState())
                postCell.likeButton.setBackgroundImage(UIImage(named: "heart.png"), for: UIControlState())
            } else {
                postCell.likeButton.setTitle("liked", for: UIControlState())
                postCell.likeButton.setBackgroundImage(UIImage(named: "heart-2.png"), for: UIControlState())
            }
            
        }
        
        //count how many likes the post has received
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("likeTo", equalTo: postCell.uuidLabel.text!)
        countLikes.countObjectsInBackground { (count, error) -> Void in
            //print("count = \(count)")
            postCell.likeNumLabel.text = "\(count)"
        }
        
        //assign an index to the username, comment and more buttons
        postCell.usernameButton.layer.setValue(indexPath, forKey: "index")
        postCell.commentButton.layer.setValue(indexPath, forKey: "index")
        postCell.moreButton.layer.setValue(indexPath, forKey: "index")
        
        //implementing @ mentions
        postCell.descriptionLabel.userHandleLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.dropFirst()) //drop the @ symbol
            
            //if the @mention is referring to the current user, go to the homescreen view controller
            if mention.lowercased() == PFUser.current()?.username {
                let goHome = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
                self.navigationController?.pushViewController(goHome, animated: true)
            } else {
                //else, direct the user to the profile mentioned
                guestUsername.append(mention.lowercased())
                let goGuest = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! GuestViewController
                self.navigationController?.pushViewController(goGuest, animated: true)
            }
        }
        
        //if a hashtag in the post description is tapped
        
        postCell.descriptionLabel.hashtagLinkTapHandler = { label, handle, range in
            var hashtag = handle
            hashtag = String(hashtag.dropFirst())
            
            //storing the hashtag in the storage array inside Hashtag View Controller
            //will be used to display all the relevant info
            hashtagArray.append(hashtag.lowercased())
            
            //sending the user to the HashtagViewController
            let goHashtag = self.storyboard?.instantiateViewController(withIdentifier: "HashtagViewController") as! HashtagViewController
            self.navigationController?.pushViewController(goHashtag, animated: true)
        }
        
        return postCell
    }
    
    //reacting to pressing on the username
    @IBAction func username_pressed(_ sender: UIButton) {
        
        //get the index of the current username in the PostCell
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        //send the user to either home or guest view, depending on the post author
        if cell.usernameButton.titleLabel?.text == PFUser.current()?.username {
            let goHome = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
            self.navigationController?.pushViewController(goHome, animated: true)
        } else {
            guestUsername.append(cell.usernameButton.titleLabel!.text!)
            let goGuest = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! GuestViewController
            self.navigationController?.pushViewController(goGuest, animated: true)
        }
    }
    
    //MARK: - Handling the comment button
    @IBAction func commentButton_pressed(_ sender: UIButton) {
        //get the comment button index
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        //send the current username and the uuid to the global
        //arrays in CommentViewController
        commentUUID.append(cell.uuidLabel.text!)
        commentOwner.append(cell.usernameButton.titleLabel!.text!)
        
        //send the user to CommentViewController
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    @IBAction func moreButton_pressed(_ sender: UIButton) {
        //get the index for more button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        //MARK: - Implementing 'Delete post'
        
        let delete = UIAlertAction(title: "Delete post", style: .default) { (UIAlertAction) -> Void in
            
            //Delete the row with the post from the table view
            self.usernameArray.remove(at: i.row)
            self.avatarArray.remove(at: i.row)
            self.postDateArray.remove(at: i.row)
            self.postImageArray.remove(at: i.row)
            self.postDescriptionArray.remove(at: i.row)
            self.UUIDArray.remove(at: i.row)
            
            //Delete the post from the server
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: cell.uuidLabel.text!)
            postQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success {
                                //update the collection view
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadedPost"), object: nil)
                                //return to the previous view controller
                                _ = self.navigationController?.popViewController(animated: true)
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
            //delete the post likes from the server
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("to", equalTo: cell.uuidLabel.text!)
            likeQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            //delete the post comments from the server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("likeTo", equalTo: cell.uuidLabel.text!)
            commentQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            //delete the post hashtags from the server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("toComment", equalTo: cell.uuidLabel.text!)
            hashtagQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
        }
        
        //MARK: - Implementing 'report inappropriate post'
        let complaint = UIAlertAction(title: "Report this post", style: .default) { (UIAlertAction) -> Void in
            
            // send complain to server
            let complainObject = PFObject(className: "complaint")
            complainObject["by"] = PFUser.current()?.username
            complainObject["about"] = cell.uuidLabel.text
            complainObject["owner"] = cell.usernameButton.titleLabel?.text
            complainObject.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.showAlert(title: "Report successful", message: "Thank You! We will investigate your complaint")
                } else {
                    self.showAlert(title: "Error", message: error!.localizedDescription)
                }
            })
        }
        
        
        //define a menu that will be shown when the button is pressed
        let menu = UIAlertController(title: "More options", message: nil, preferredStyle: .actionSheet)
        //add a cancel option
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //assign the available actions to the menu
        //make sure that users can delete only their own posts
        if cell.usernameButton.titleLabel?.text == PFUser.current()?.username {
            menu.addAction(delete)
            menu.addAction(cancel)
        } else {
            menu.addAction(complaint)
            menu.addAction(cancel)
        }
        
        //present the menu with the options
        self.present(menu, animated: true, completion: nil)
    }
    
    //shows an alert with error and message that were passed
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(alertButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    

}
