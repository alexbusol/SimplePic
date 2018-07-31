//
//  CommentViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/31/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

//global arrays holding unique comment data
var commentUUID = [String]()
var commentOwner = [String]()

class CommentViewController: UIViewController, UITextViewDelegate, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    var refresh = UIRefreshControl()
    
    //default values for the CommentViewController
    var tableViewHeight : CGFloat = 0
    var commentYpos : CGFloat = 0
    var commentHeight : CGFloat = 0
    
    //storrage arrays for data received from the Database
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var commentArray = [String]()
    var dateArray = [Date?]()
    
    // variable to hold keybarod frame
    var keyboard = CGRect()
    
    // page size
    var page : Int32 = 15
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configuring the delegates
        commentTextField.delegate = self
        tableView.delegate = self
        
        configureLayout()
    }
    
    //gets called when the commentview appears
    override func viewWillAppear(_ animated: Bool) {
        //hide the tab bar when writing a comment
        self.tabBarController?.tabBar.isHidden = true
        commentTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    
    //setting layout constraints programatically
    func configureLayout() {
        
        //getting the current screen's dimensions
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - self.navigationController!.navigationBar.frame.size.height - 20)
        tableView.estimatedRowHeight = width / 5.333
        tableView.rowHeight = UITableViewAutomaticDimension
        
        commentTextField.frame = CGRect(x: 10, y: tableView.frame.size.height + height / 56.8, width: width / 1.306, height: 33)
        commentTextField.layer.cornerRadius = commentTextField.frame.size.width / 50
        
        sendButton.frame = CGRect(x: commentTextField.frame.origin.x + commentTextField.frame.size.width + width / 32, y: commentTextField.frame.origin.y, width: width - (commentTextField.frame.origin.x + commentTextField.frame.size.width) - (width / 32) * 2, height: commentTextField.frame.size.height)
        
        tableViewHeight = tableView.frame.size.height
        commentHeight = commentTextField.frame.size.height
        commentYpos = commentTextField.frame.origin.y
    }

}
