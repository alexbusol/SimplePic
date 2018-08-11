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
                    fullnameQuery?.whereKey("FullName", matchesRegex: "(?i)" + self.searchBar.text!)
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
    
    
    //MARK: - Table View methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FollowerCell
        
        //hide the follow button in the search results
        cell.followButton.isHidden = true
        
        //place data from the server into the FollowerCell items
        cell.username.text = usernameArray[indexPath.row]
        avatarArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.userImage.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    //if one of the found users was selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FollowerCell
        
        //send the user to the right view
        if cell.username.text! == PFUser.current()?.username {
            let goHome = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
            self.navigationController?.pushViewController(goHome, animated: true)
        } else {
            guestUsername.append(cell.username.text!)
            let goGuest = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! GuestViewController
            self.navigationController?.pushViewController(goGuest, animated: true)
        }
    }
    
    

}
