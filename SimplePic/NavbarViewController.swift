//
//  NavbarViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/30/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

class NavbarViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    func configureLayout() {
        //set the foreground color of the navbar
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        //set the button color
        self.navigationBar.tintColor = .white
        
        //set the background color
        self.navigationBar.barTintColor = UIColor(red: 18.0 / 255.0, green: 86.0 / 255.0, blue: 136.0 / 255.0, alpha: 1)
        
        //disable navbar translucency
        self.navigationBar.isTranslucent = false
    }
    
    //make sure the status bar remains white
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

}
