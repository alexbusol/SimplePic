//
//  CommentCell.swift
//  SimplePic
//
//  Created by Alex Busol on 7/31/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var commentLabel: KILabel!
    @IBOutlet weak var commentDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureLayout()
    }
    
    //setting layout constraints programatically
    func configureLayout() {
        
        userAvatar.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentDate.translatesAutoresizingMaskIntoConstraints = false
 
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-5-[username]-(-2)-[comment]-5-|",
            options: [], metrics: nil, views: ["username":usernameButton, "comment":commentLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-15-[date]",
            options: [], metrics: nil, views: ["date":commentDate]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[ava(40)]",
            options: [], metrics: nil, views: ["ava":userAvatar]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[ava(40)]-13-[comment]-20-|",
            options: [], metrics: nil, views: ["ava":userAvatar, "comment":commentLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[ava]-13-[username]",
            options: [], metrics: nil, views: ["ava":userAvatar, "username":usernameButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[date]-10-|",
            options: [], metrics: nil, views: ["date":commentDate]))
        
        
        //roundig the user's avatar near the comment text
        userAvatar.layer.cornerRadius = userAvatar.frame.size.width / 2
        userAvatar.clipsToBounds = true
    }

}
