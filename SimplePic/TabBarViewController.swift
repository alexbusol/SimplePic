//
//  TabBarViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/30/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }

    func configureLayout() {
        //change button color
        self.tabBar.tintColor = .white
        
        //change background color
        self.tabBar.barTintColor = UIColor(red: 37.0 / 255.0, green: 39.0 / 255.0, blue: 42.0 / 255.0, alpha: 1)
        
        //disable translucency
        self.tabBar.isTranslucent = false
    }
}
