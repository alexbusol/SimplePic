//
//  NotificationCell.swift
//  SimplePic
//
//  Created by Alex Busol on 11/2/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureLayout()
    }
    
    //setting up layout
    func configureLayout() {

        userImage.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[ava(30)]-10-[username]-7-[info]-7-[date]",
            options: [], metrics: nil, views: ["ava":userImage, "username":usernameButton, "info":informationLabel, "date":dateLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[ava(30)]-10-|",
            options: [], metrics: nil, views: ["ava":userImage]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[username(30)]",
            options: [], metrics: nil, views: ["username":usernameButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[info(30)]",
            options: [], metrics: nil, views: ["info":informationLabel]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[date(30)]",
            options: [], metrics: nil, views: ["date":dateLabel]))
        
        // round the avatar
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
    }


}
