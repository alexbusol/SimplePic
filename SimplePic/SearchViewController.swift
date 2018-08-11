//
//  SearchViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 8/11/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    //declare the search bar 
    var searchBar = UISearchBar()
    
    //storage arrays for data received from the Database
    var usernameArray = [String]()
    var avatarArray = [PFFile]()
    var postDateArray = [Date?]()
    var postImageArray = [PFFile]()
    var postDescriptionArray = [String]()
    var UUIDArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the search bar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.size.width - 34
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
    }

}
