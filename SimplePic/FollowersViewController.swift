//
//  FollowersViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/25/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

var showCategory = String()
var user = String()
class FollowersViewController: UITableViewController {
    
    //arrays to hold the usernames and avatars of the followers/following from the user class of the database
    var usernameArray = [String]()
    var avatarArray = [PFFile]()
    
    //holds the followers/followings from the follow class of the database
    var followArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //showing the category of the table view at the top (following/followers)
        self.navigationItem.title = showCategory.uppercased()
        
        //decide whether to load followers or following
        if showCategory == "followers" {
            loadFollowers()
        } else if showCategory == "following" {
            loadFollowing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFollowers() {
        //query the database for the current user's followers
        
        let whoFollows = PFQuery(className: "follow")
        whoFollows.whereKey("following", equalTo: user) //asking the DB to show the followers for current user
        whoFollows.findObjectsInBackground (block: { (objects, error) -> Void in
            //if there's no error retrieving the followers
            if error == nil {
                
                //make sure that the current followers array is empty
                self.followArray.removeAll(keepingCapacity: false)
                
                //store the received followers in the followArray
                for object in objects! {
                    self.followArray.append(object.value(forKey: "follower") as! String)
                }
                
                //pull the usernames and avatars of the users following the current user from the USER CLASS
                //this is based on the data stored in the followArray, which was received from the FOLLOW CLASS in the database
                let followersData = PFUser.query()
                followersData?.whereKey("username", containedIn: self.followArray)
                //sort the received followers in descending order from when they followed the current user
                followersData?.addDescendingOrder("createdAt")
                followersData?.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        //make sure that the storage arrays are empty
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avatarArray.removeAll(keepingCapacity: false)
                        
                        //assign the data received to the username and avatar storage for the table cells
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avatarArray.append(object.object(forKey: "avatar") as! PFFile)
                            self.tableView.reloadData() //reload the table view to show the most up to date info
                        }
                    } else {
                        print("Unable to pull the followers data from the USER CLASS of the DB \(error!.localizedDescription)")
                    }
                })
                
            } else {
                print("Unable to pull the followers data from the FOLLOW CLASS of the DB  \(error!.localizedDescription)")
            }
        })
    }
    
    func loadFollowing() {
        let whoFollowing = PFQuery(className: "follow")
        
        whoFollowing.whereKey("follower", equalTo: user) //asking the DB to get the followings from the follow class for current user
        whoFollowing.findObjectsInBackground { (objects, error) in
            //if there's no error retrieving the followings
            if error == nil {
               
                //make sure that the current followings array is empty
                self.followArray.removeAll(keepingCapacity: false)
                
                //store the received followings from the follow class in the followArray
                for object in objects! {
                    self.followArray.append(object.value(forKey: "following") as! String)
                }
                
                //pull the usernames and avatars of the users followed by the current user from the USER CLASS
                //this is based on the data stored in the followArray, which was received from the FOLLOW CLASS in the database
                let followingData = PFUser.query() //querying the user class for the info based on the followArray
                followingData?.whereKey("username", containedIn: self.followArray)
                //sort the received followings in descending order from when they followed the current user
                followingData?.addDescendingOrder("createdAt")
                followingData?.findObjectsInBackground(block: { (objects, error) -> Void in
        
                    if error == nil {
                        
                       //making sure that the storage arrays are empty
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avatarArray.removeAll(keepingCapacity: false)
                        
                        //assign the data received to the username and avatar storage for the table cells
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            
                            if let avatarReceived = object.object(forKey: "avatar") as? PFFile {
                                self.avatarArray.append(avatarReceived)
                            } 
                            self.tableView.reloadData() //reload the table view to show the most up to date info
                        }
                    } else {
                        print("Unable to pull the following data from the USER CLASS of the DB \(error!.localizedDescription)")
                    }
                })
                
            } else {
                print("Unable to pull the following data from the USER CLASS of the DB \(error!.localizedDescription)")
            }
        }
        
    }
    //show as many cells as there are users in the followers/following categories
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    //MARK: - place the avatar and username into the table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FollowerCell
        tableCell.username.text = usernameArray[indexPath.row]
        avatarArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                tableCell.userImage.image = UIImage(data: data!)
            } else {
                print("Unable to place the data into table cells \(error!.localizedDescription)")
            }
        }
        //change the follow button depending on whether the current user follows the follower
        let isFollowing = PFQuery(className: "follow")
        isFollowing.whereKey("follower", equalTo: PFUser.current()?.username)
        isFollowing.whereKey("following", equalTo: tableCell.username.text) //check if the current user follows the follower
        isFollowing.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                if count == 0 { //if current user is not following the follower, set the botton title to follow
                    tableCell.followButton.setTitle("Follow", for: UIControlState())
                    tableCell.followButton.backgroundColor = .lightGray
                } else {
                    tableCell.followButton.setTitle("Following", for: UIControlState())
                    tableCell.followButton.backgroundColor = UIColor.blue
                }
            }
        })
        
        //hide the follow button for the current user
        if tableCell.username.text == PFUser.current()?.username {
            tableCell.followButton.isHidden = true
        }
        
        return tableCell
    }
    //MARK: - Handling tapping on a user in followers/following
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableCell = tableView.cellForRow(at: indexPath) as! FollowerCell
        
        //if user taps on himself, go to homeview. else, go to another user's page
        if tableCell.username.text! == PFUser.current()!.username {
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
            self.navigationController?.pushViewController(homeVC, animated: true)
        } else { //go to another user's profile
            //pass the username of the target profile to the GuestViewController's global array guestUsername.
            guestUsername.append(tableCell.username.text!)
            let guestVC = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! GuestViewController
            self.navigationController?.pushViewController(guestVC, animated: true)
        }
    }
    
    //changing the height of a follower cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }
}
