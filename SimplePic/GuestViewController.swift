//
//  GuestViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/25/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"

var guestUsername = [String]() //holds the username for the profile the user is about to view

class GuestViewController: UICollectionViewController {
    
    //for refreshing the page when pulling down
    var toRefresh : UIRefreshControl!
    
    //Determines how many pictures does our app load at one time
    var pageSize : Int = 12
    
    //hold the pictures and the IDS of the cells on screen
    var uuidArray = [String]()
    var pictureArray = [PFFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //allow the user to scroll downward even if there's not enough images in the view
        //the view bounces back after the user stops scrolling
        self.collectionView?.alwaysBounceVertical = true
        //showing the the last visited username in the navbar
        self.navigationItem.title = guestUsername.last
        
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(GuestViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        //implementing pull to refresh
        toRefresh = UIRefreshControl()
        toRefresh.addTarget(self, action: #selector(GuestViewController.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(toRefresh)
        
        //implementing swipe right to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GuestViewController.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
       
        

    }
    //MARK: - when back button is pressed, send the user to the previous page visited
    @objc func back(_ sender : UIBarButtonItem) {
        
        // push back
        _ = self.navigationController?.popViewController(animated: true)
        
        // clean guest username or deduct the last guest userame from guestname = Array
        if !guestUsername.isEmpty {
            guestUsername.removeLast()
        }
    }
    
    @objc func refresh() {
        toRefresh.endRefreshing()
        //loadPosts()
    }
    
}
