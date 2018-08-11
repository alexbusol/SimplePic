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
        
        loadUsers()
    }
    
    //MARK: - Load some initial users into the table view
    func loadUsers() {
        
        let usersQuery = PFQuery(className: "_User")
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avatarArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.usernameArray.append(object.value(forKey: "username") as! String)
                    self.avatarArray.append(object.value(forKey: "avatar") as! PFFile)
                }
                
                self.tableView.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }

    //MARK: - Implement search by both full names and usernames
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //first, search by username
        let usernameQuery = PFQuery(className: "_User")
        usernameQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        usernameQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                //if usernameQuery returned nno items
                if objects!.isEmpty {
                    
                    let fullnameQuery = PFUser.query()
                    fullnameQuery?.whereKey("fullname", matchesRegex: "(?i)" + self.searchBar.text!)
                    fullnameQuery?.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {

                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avatarArray.removeAll(keepingCapacity: false)
                            
                            for object in objects! {
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.avatarArray.append(object.object(forKey: "avatar") as! PFFile)
                            }
                            
                            self.tableView.reloadData()
                            
                        }
                    })
                }
                
                //process the userQuery results if the search result wasnt empty
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avatarArray.removeAll(keepingCapacity: false)

                for object in objects! {
                    self.usernameArray.append(object.object(forKey: "username") as! String)
                    self.avatarArray.append(object.object(forKey: "avatar") as! PFFile)
                }
                
                self.tableView.reloadData()
                
            }
        })
        
        return true
    }
    
    //tapped on the searchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //show the cancel button
        searchBar.showsCancelButton = true
    }
    
    //tapped on the search bar cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //dismiss the keyboard
        searchBar.resignFirstResponder()
        searchBar.text = ""
        //hide the cancel button
        searchBar.showsCancelButton = false
        
        loadUsers()
    }

}
