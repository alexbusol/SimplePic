//
//  PostViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/28/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

var postUUID = [String]() //holds unique identifiers of posts

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
        let backButton = UIBarButtonItem(title: "back", style: .plain, target: self, action: "back")
        self.navigationItem.leftBarButtonItem = backButton
        
        //implementing a swipe right gesture to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: "back")
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        //need to make the PostCell height dynamic depending on the amount
        //of text in the post description
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        
        //find the post the user clicked on
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: postUUID.last!)
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
        
        
        return postCell
    }

    //number of cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 //return 1 cell because only 1 picture will be shown
    }
}
