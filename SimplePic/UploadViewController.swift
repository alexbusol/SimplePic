//
//  UploadViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/26/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

class UploadViewController: UIViewController {

    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var publishButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
    }
    
    //setting UI layout constraints programatically
    func configureLayout() {
        //getting the width and height of the current screen
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        userPicture.frame = CGRect(x: 15, y: 15, width: width / 4.5, height: width / 4.5)
        titleTextView.frame = CGRect(x: userPicture.frame.size.width + 25, y: userPicture.frame.origin.y, width: width / 1.488, height: userPicture.frame.size.height)
        publishButton.frame = CGRect(x: 0, y: height / 1.09, width: width, height: width / 8)

    }

}
