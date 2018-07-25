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
                } else {
                    print("There was an error following the user \(error?.localizedDescription)")
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
    
}
