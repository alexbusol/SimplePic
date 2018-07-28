//
//  PostCell.swift
//  SimplePic
//
//  Created by Alex Busol on 7/28/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

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
        configureLayout()
    }
    //set constraints programatically
    func configureLayout() {
        
        
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

    
}
