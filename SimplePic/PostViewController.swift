//
//  PostViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/28/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

var postToLoadUUID = [String]() //holds unique identifiers of posts received after user clicks on a post in Home/Guest view

class PostViewController: UITableViewController {
    
    //arrays to hold infromation about the posts that will be displayed
    //in PostViewController
    var userNameArray = [String]()
    var userAvatarArray = [PFFile]()
    var postDateArray = [Date?]()
    var postPictureArray = [PFFile]()
    var uuidArray = [String]()
    var descriptionArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "test" //change later
        self.navigationItem.hidesBackButton = true
        //creating a button that lets the user to go back to a previous screen
        let backButton = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(PostViewController.goBack(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        //implementing a swipe right gesture to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PostViewController.goBack(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        //receive notification from post cell to update data in the Post View
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        //need to make the PostCell height dynamic depending on the amount
        //of text in the post description
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 500
        
        //find the post the user clicked on
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: postToLoadUUID.last!)
        postQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                
                //clean up the storage arrays
                self.userAvatarArray.removeAll(keepingCapacity: false)
                self.userNameArray.removeAll(keepingCapacity: false)
                self.postDateArray.removeAll(keepingCapacity: false)
                self.postPictureArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.descriptionArray.removeAll(keepingCapacity: false)

                //place the objects retrieved from the database into PostViewController
                for object in objects! {
                    self.userAvatarArray.append(object.value(forKey: "avatar") as! PFFile)
                    self.userNameArray.append(object.value(forKey: "username") as! String)
                    self.postDateArray.append(object.createdAt)
                    self.postPictureArray.append(object.value(forKey: "pic") as! PFFile)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.descriptionArray.append(object.value(forKey: "title") as! String)
             
                }
                
                self.tableView.reloadData()
            }
        }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //define a tableViewCell
        let postCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        //place the data from the storage arrays into the cell
        postCell.usernameButton.setTitle(userNameArray[indexPath.row], for: .normal) //changing the title of the username button to the post creator's username
        postCell.uuidLabel.text = uuidArray[indexPath.row]
        postCell.descriptionLabel.text = descriptionArray[indexPath.row]
        postCell.descriptionLabel.sizeToFit()
        userAvatarArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil {
                postCell.userAvatar.image = UIImage(data: data!)
            }
        }
        postPictureArray[indexPath.row].getDataInBackground { (data, error) in
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
        
        //assign an index to the username and comment buttons
        postCell.usernameButton.layer.setValue(indexPath, forKey: "index")
        postCell.commentButton.layer.setValue(indexPath, forKey: "index")
        
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
    
    @objc func goBack(_ sender: UIBarButtonItem) {
        //return to the previous viewController
        self.navigationController?.popViewController(animated: true)
        
        //remove the post uuid from the visited array
        if !postToLoadUUID.isEmpty {
            postToLoadUUID.removeLast()
        }
    }
    
    @objc func refresh() {
        self.tableView.reloadData()
    }

    //number of cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNameArray.count
    }
}
