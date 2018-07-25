//
//  FollowerCell.swift
//  SimplePic
//
//  Created by Alex Busol on 7/25/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

class FollowerCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
    }
    
    
    @IBAction func followButton_Pressed(_ sender: UIButton) {
        
        let buttonTitle = followButton.title(for: UIControlState())
        
        //if not following -> follow routine
        if buttonTitle == "Follow" {
            //creating new object in the follow class
            let object = PFObject(className: "follow")
            //placing the current user in the followers of the target user
            object["follower"] = PFUser.current()?.username
            object["following"] = username.text //placing the target user in the following list of the current user
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.followButton.setTitle("Following", for: UIControlState())
                    self.followButton.backgroundColor = .blue
                } else {
                    print("There was an error following the user \(error?.localizedDescription)")
                }
            })
        } else { //if following -> unfollow routine
            let toUnfollow = PFQuery(className: "follow")
            //looking for the user for which unfollow was clicked
            toUnfollow.whereKey("follower", equalTo: PFUser.current()!.username!)
            toUnfollow.whereKey("following", equalTo: username.text!)
            //delete the following connection from the database
            toUnfollow.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success {
                                self.followButton.setTitle("Follow", for: UIControlState())
                                self.followButton.backgroundColor = .lightGray
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

