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
            postCell.postDateLabel.text = "\(String(describing: timeDifference.second))s." //display the difference in seconds
        }
        //if the time difference is less than 1 hour
        if timeDifference.minute! > 0 && timeDifference.hour! == 0 {
            postCell.postDateLabel.text = "\(String(describing: timeDifference.minute))m." //display the difference in minutes
        }
        //if the time difference is less than 1 day
        if timeDifference.hour! > 0 && timeDifference.day! == 0 {
            postCell.postDateLabel.text = "\(String(describing: timeDifference.hour))h." //display the difference in hours
        }
        //if the time difference is less than 1 week
        if timeDifference.day! > 0 && timeDifference.weekOfMonth! == 0 {
            postCell.postDateLabel.text = "\(String(describing: timeDifference.day))d." //display the difference in days
        }
        //if the time difference is more than 1 week
        if timeDifference.weekOfMonth! > 0 {
            postCell.postDateLabel.text = "\(String(describing: timeDifference.weekOfMonth))w." //display the difference in weeks
        }
        
        
        return postCell
        
    }
    
    @objc func goBack(_ sender: UIBarButtonItem) {
        //return to the previous viewController
        self.navigationController?.popViewController(animated: true)
        
        //remove the post uuid from the visited array
        if !postToLoadUUID.isEmpty {
            postToLoadUUID.removeLast()
        }
    }

    //number of cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNameArray.count
    }
}
