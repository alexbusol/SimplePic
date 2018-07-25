//
//  FollowerCell.swift
//  SimplePic
//
//  Created by Alex Busol on 7/25/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

class FollowerCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
