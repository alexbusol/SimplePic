//
//  PostCell.swift
//  SimplePic
//
//  Created by Alex Busol on 7/28/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

class PostCell: UITableViewCell {
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var postDateLabel: UILabel!
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var likeNumLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //declaring a double tap to like gesture
        let doubleTap = UITapGestureRecognizer(target: self, action: "likeDoubleTap")
        doubleTap.numberOfTapsRequired = 2
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(doubleTap)
        
        configureLayout()
    }
    //set constraints programatically
    func configureLayout() {
        
        likeButton.setTitleColor(UIColor.clear, for: UIControlState())
        //disable automatic autoresizing
        userAvatar.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        postDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        postImage.translatesAutoresizingMaskIntoConstraints = false
        
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        likeNumLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        uuidLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //get the current screen's width
        let pictureWidth = UIScreen.main.bounds.width
        
        //set constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[ava(30)]-10-[pic(\(pictureWidth))]-5-[like(30)]",
            options: [], metrics: nil, views: ["ava":userAvatar, "pic":postImage, "like":likeButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[username]",
            options: [], metrics: nil, views: ["username":usernameButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[pic]-5-[comment(30)]",
            options: [], metrics: nil, views: ["pic":postImage, "comment":commentButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-15-[date]",
            options: [], metrics: nil, views: ["date":postDateLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[like]-5-[title]-5-|",
            options: [], metrics: nil, views: ["like":likeButton, "title":descriptionLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[pic]-5-[more(30)]",
            options: [], metrics: nil, views: ["pic":postImage, "more":moreButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[pic]-10-[likes]",
            options: [], metrics: nil, views: ["pic":postImage, "likes":likeNumLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[ava(30)]-10-[username]",
            options: [], metrics: nil, views: ["ava":userAvatar, "username":usernameButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[pic]-0-|",
            options: [], metrics: nil, views: ["pic":postImage]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-15-[like(30)]-10-[likes]-125-[comment(30)]",
            options: [], metrics: nil, views: ["like":likeButton, "likes":likeNumLabel, "comment":commentButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[more(30)]-15-|",
            options: [], metrics: nil, views: ["more":moreButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-15-[title]-15-|",
            options: [], metrics: nil, views: ["title":descriptionLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[date]-10-|",
            options: [], metrics: nil, views: ["date":postDateLabel]))
        
        //round the avatar near the username
        userAvatar.layer.cornerRadius = userAvatar.frame.size.width / 2
        userAvatar.clipsToBounds = true
    }
    
    //MARK: - Respond to pressing the like button
    @IBAction func likeButton_pressed(_ sender: AnyObject) {
        
        let title = sender.title(for: UIControlState())
        
        //if the user did not like the post yet
        if title == "unliked" {
            
            //recording a new like in the DB
            let object = PFObject(className: "likes")
            object["likedBy"] = PFUser.current()?.username
            object["likeTo"] = uuidLabel.text
            //saving the new data
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    //changing the like state
                    self.likeButton.setTitle("liked", for: UIControlState())
                    self.likeButton.setBackgroundImage(UIImage(named: "heart-2.png"), for: UIControlState())

                    //send a notification to refresh the Post View and display the new data
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                } else {
                    print(String(describing: error?.localizedDescription))
                }
            })
            
        //if the user already liked the post and wants to dislike ti
        } else {
            
            //getting the existing like from the database
            let query = PFQuery(className: "likes")
            query.whereKey("likedBy", equalTo: PFUser.current()!.username!)
            query.whereKey("likeTo", equalTo: uuidLabel.text!)
            query.findObjectsInBackground { (objects, error) -> Void in
                for object in objects! {
                    
                    //delete the user's like from the DB
                    object.deleteInBackground(block: { (success, error) -> Void in
                        if success {
                            self.likeButton.setTitle("unliked", for: UIControlState())
                            self.likeButton.setBackgroundImage(UIImage(named: "heart.png"), for: UIControlState())
                           
                            //send a notification to refresh the Post View and display the new data
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                            
                        } else {
                            print(String(describing: error?.localizedDescription))
                        }
                    })
                }
            }
            
        }
        
    }
    
    //MARK: - Double tap to like
    @objc func likeDoubleTap() {
        //adding an image that will pop over the post image for a moment
        let likeOverlay = UIImageView(image: UIImage(named: "heart.png"))
        //specifying where the overlaying image will be displayed
        likeOverlay.frame.size.width = postImage.frame.size.width / 1.5
        likeOverlay.frame.size.height = postImage.frame.size.width / 1.5
        likeOverlay.center = postImage.center
        //making it semi-transparent
        likeOverlay.alpha = 0.7
        
        self.addSubview(likeOverlay)
        
        //adding the animation making the overlay disappear shortly after the double tap
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            likeOverlay.alpha = 0
            likeOverlay.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        })
        
        likeButton_pressed(likeButton)

    }

    
}
