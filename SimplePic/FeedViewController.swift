//
//  FeedViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 8/10/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UITableViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var toRefresh = UIRefreshControl()
    
    //storage arrays for data received from the Database
    var usernameArray = [String]()
    var avatarArray = [PFFile]()
    var postDateArray = [Date?]()
    var postImageArray = [PFFile]()
    var postDescriptionArray = [String]()
    var UUIDArray = [String]()
    
    var followingArray = [String]()
    
    var pageSize : Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Your feed"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        //implementing 'pull to refresh'
        toRefresh.addTarget(self, action: #selector(FeedViewController.loadPosts), for: UIControlEvents.valueChanged)
        tableView.addSubview(toRefresh)
        
        //placing the indicator in the center horizontally
        indicator.center.x = tableView.center.x
        
        loadPosts()
    }
    
    func refresh() {
        tableView.reloadData()
    }

    func updateTableView(_ notification:Notification) {
        loadPosts()
    }
    
    //MARK: - Load the posts of the people who the user is following
    @objc func loadPosts() {
        
        //query the database for the current user's followings
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                //make sure the storage arrays are empty
                self.followingArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.followingArray.append(object.object(forKey: "following") as! String)
                }
                
                //include the current user in the following array to display the user's post in the feed
                self.followingArray.append(PFUser.current()!.username!)
                
                //query the database for the posts
                let postsQuery = PFQuery(className: "posts")
                postsQuery.whereKey("username", containedIn: self.followingArray)
                postsQuery.limit = self.pageSize
                postsQuery.addDescendingOrder("createdAt")
                postsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        //make sure the storage arrays are empty
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avatarArray.removeAll(keepingCapacity: false)
                        self.postDateArray.removeAll(keepingCapacity: false)
                        self.postImageArray.removeAll(keepingCapacity: false)
                        self.postDescriptionArray.removeAll(keepingCapacity: false)
                        self.UUIDArray.removeAll(keepingCapacity: false)
                        
                        //place the query results into the storage arrays
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avatarArray.append(object.object(forKey: "avatar") as! PFFile)
                            self.postDateArray.append(object.createdAt)
                            self.postImageArray.append(object.object(forKey: "pic") as! PFFile)
                            self.postDescriptionArray.append(object.object(forKey: "title") as! String)
                            self.UUIDArray.append(object.object(forKey: "uuid") as! String)
                        }
                        
                        //reload the table view and end the refreshing animation
                        self.tableView.reloadData()
                        self.toRefresh.endRefreshing()
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    //user scrolled to the bottom of the table View and there are more posts left to display
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            loadAdditionalPosts()
        }
    }
    
    func loadAdditionalPosts() {
        if pageSize <= UUIDArray.count {
            
            //start the loading animation
            indicator.startAnimating()
            
            //increase the page size
            pageSize = pageSize + 10
            
            
            loadPosts()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UUIDArray.count
    }
    

}
