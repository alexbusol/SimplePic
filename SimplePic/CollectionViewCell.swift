//
//  CollectionViewCell.swift
//  SimplePic
//
//  Created by Alex Busol on 7/24/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageInCell: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //setting layout constraints programatically
        let width = UIScreen.main.bounds.width //find the width of the current screen
        imageInCell.frame = CGRect(x: 0, y: 0, width: width / 3, height: width / 3)
    }
}
