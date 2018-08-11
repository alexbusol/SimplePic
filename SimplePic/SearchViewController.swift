//
//  SearchViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 8/11/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

class SearchViewController: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //declare the search bar 
    var searchBar = UISearchBar()
    
    //storage arrays for data received from the Database
    var usernameArray = [String]()
    var avatarArray = [PFFile]()
    var postDateArray = [Date?]()
    var postImageArray = [PFFile]()
    var postDescriptionArray = [String]()
    var UUIDArray = [String]()
    var imageArray = [PFFile]()
    var pageSize : Int = 15
    //declare collection view to be used in displaying popular posts
    var collectionView : UICollectionView!

    
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
        collectionViewLaunch()
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
        //show the image grid with recent posts of other users if the search bar wasnt pressed
        collectionView.isHidden = true
        
        //show the cancel button
        searchBar.showsCancelButton = true
    }
    
    //tapped on the search bar cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //hide the image grid
        collectionView.isHidden = false
        
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
    
    
    //MARK: - Setting up collection view for displaying popular posts
    func collectionViewLaunch() {
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - 20)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        loadPosts()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    //MARK: - Place post image into a collection view cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let cellImage = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        cell.addSubview(cellImage)
        
        imageArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cellImage.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }
    
    //MARK: - If one of the collection cells is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //place the uuid of the post into the global UUID array in the post view controller
        postToLoadUUID.append(UUIDArray[indexPath.row])
        
        //present PostViewController with the selected image
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    //Load posts into the image grid
    func loadPosts() {
        let query = PFQuery(className: "posts")
        query.limit = pageSize
        query.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                
                self.imageArray.removeAll(keepingCapacity: false)
                self.UUIDArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.imageArray.append(object.object(forKey: "pic") as! PFFile)
                    self.UUIDArray.append(object.object(forKey: "uuid") as! String)
                }

                self.collectionView.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    //load more posts if scrolled to the bottom and there are more posts left to display
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            self.loadAdditionalPosts()
        }
    }
    
    func loadAdditionalPosts() {
        
        if pageSize <= imageArray.count {
            
            //increase the page size
            pageSize = pageSize + 15
            
            //load additional posts
            loadPosts()
            
        }
        
    }
    

}
