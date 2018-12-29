//
//  HeaderViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/24/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

class HeaderView: UICollectionReusableView {
        
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var websiteTextField: UITextView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var postsNum: UILabel!
    @IBOutlet weak var followersNum: UILabel!
    @IBOutlet weak var followingNum: UILabel!
    @IBOutlet weak var postsSub: UILabel!
    @IBOutlet weak var followersSub: UILabel!
    @IBOutlet weak var followingSub: UILabel!
    @IBOutlet weak var profileActionButton: UIButton!
    
    @IBAction func guestFollowButton_clicked(_ sender: UIButton) {
        let buttonTitle = profileActionButton.title(for: UIControlState())
        
        //if not following -> follow routine
        if buttonTitle == "Follow" {
            //creating new object in the follow class
            let object = PFObject(className: "follow")
            //placing the current user in the followers of the target user
            object["follower"] = PFUser.current()?.username
            object["following"] = guestUsername.last! //placing the target user in the following list of the current user
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.profileActionButton.setTitle("Following", for: UIControlState())
                    self.profileActionButton.backgroundColor = .blue
                    
                    //send notification if followed
                    let notificationObject = PFObject(className: "notifications")
                    notificationObject["by"] = PFUser.current()?.username
                    notificationObject["to"] = guestUsername.last
                    notificationObject["avatar"] = PFUser.current()?.object(forKey: "avatar") as! PFFile
                    notificationObject["commentOwner"] = ""
                    notificationObject["uuid"] = ""
                    notificationObject["notification_type"] = "follow"
                    notificationObject["seen"] = "no"
                    notificationObject.saveEventually()
                } else {
                    print("There was an error when trying to follow the user \(error?.localizedDescription)")
                }
            })
        } else { //if following -> unfollow routine
            let toUnfollow = PFQuery(className: "follow")
            //looking for the user for which unfollow was clicked
            toUnfollow.whereKey("follower", equalTo: PFUser.current()!.username!)
            toUnfollow.whereKey("following", equalTo: guestUsername.last!)
            //delete the following connection from the database
            toUnfollow.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success {
                                self.profileActionButton.setTitle("Follow", for: UIControlState())
                                self.profileActionButton.backgroundColor = .lightGray
                                
                                
                                //delete notification if unfollowed
                                let notificationQuery = PFQuery(className: "notifications")
                                notificationQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                notificationQuery.whereKey("to", equalTo: guestUsername.last!)
                                notificationQuery.whereKey("notification_type", equalTo: "follow" )
                                notificationQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })
                            } else {
                                print("unable to delete the user following from the DB \(error?.localizedDescription)")
                            }
                        })
                    }
                    
                } else {
                    print("Unable to unfollow \(error?.localizedDescription)")
                    
                }
            })
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureLayout()
    }
    
    //Assigning layout constraints programatically
    func configureLayout() {
        
        
        let width = UIScreen.main.bounds.width //find the width of the current screen
        
        userImage.frame = CGRect(x: width / 16, y: width / 16, width: width / 4, height: width / 4)
        
        postsNum.frame = CGRect(x: width / 2.5, y: userImage.frame.origin.y, width: 50, height: 30)
        followersNum.frame = CGRect(x: width / 1.7, y: userImage.frame.origin.y, width: 50, height: 30)
        followingNum.frame = CGRect(x: width / 1.25, y: userImage.frame.origin.y, width: 50, height: 30)
        
        postsSub.center = CGPoint(x: postsNum.center.x, y: postsNum.center.y + 20)
        followersSub.center = CGPoint(x: followersNum.center.x, y: followersNum.center.y + 20)
        followingSub.center = CGPoint(x: followingNum.center.x, y: followingNum.center.y + 20)
        
        profileActionButton.frame = CGRect(x: postsSub.frame.origin.x, y: postsSub.center.y + 20, width: width - postsSub.frame.origin.x - 10, height: 30)
        profileActionButton.layer.cornerRadius = profileActionButton.frame.size.width / 50
        
        fullNameLabel.frame = CGRect(x: userImage.frame.origin.x, y: userImage.frame.origin.y + userImage.frame.size.height, width: width - 30, height: 30)
        websiteTextField.frame = CGRect(x: userImage.frame.origin.x - 5, y: fullNameLabel.frame.origin.y + 22, width: width - 30, height: 30)
        bioLabel.frame = CGRect(x: userImage.frame.origin.x, y: websiteTextField.frame.origin.y + 30, width: width - 30, height: 30)
    }
    
    
    
}
