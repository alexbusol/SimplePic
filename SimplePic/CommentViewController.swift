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
    
    //storage arrays for data received from the Database
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var commentArray = [String]()
    var dateArray = [Date?]()
    
    //variable to hold keybarod frame
    var keyboard = CGRect()
    
    //page size. how many cells of comments to display at first
    var pageSize : Int32 = 15
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configuring the delegates
        commentTextField.delegate = self
        tableView.delegate = self
     
        //set the navbar title
        self.navigationItem.title = "COMMENTS"
        
        //implement back button
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(CommentViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        //enable swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(CommentViewController.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        //listen for changes in keyboard states
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //disable the send button at the beginning when no comment text is entered
        sendButton.isEnabled = false
        
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
    
    //back button/swipe routine
    @objc func back(_ sender : UIBarButtonItem) {
        //go to previous View Controller
        _ = self.navigationController?.popViewController(animated: true)
        
        //remove the cancelled comment info from the global storage arrays
        if !commentUUID.isEmpty {
            commentUUID.removeLast()
        }
    
        if !commentOwner.isEmpty {
            commentOwner.removeLast()
        }
    }

    
    //MARK: - Adjusting the table view height depending on whether the keyboard is showing
    @objc func keyboardWillShow(_ notification : Notification) {
    
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        //shrink the UI vertically
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTextField.frame.size.height + self.commentHeight
            self.commentTextField.frame.origin.y = self.commentYpos - self.keyboard.height - self.commentTextField.frame.size.height + self.commentHeight
            self.sendButton.frame.origin.y = self.commentTextField.frame.origin.y
        })
    }

    @objc func keyboardWillHide(_ notification : Notification) {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.tableView.frame.size.height = self.tableViewHeight
            self.commentTextField.frame.origin.y = self.commentYpos
            self.sendButton.frame.origin.y = self.commentYpos
        })
    }
    
    //MARK: - Adjusting the text view height based on how much text is entered
    func textViewDidChange(_ textView: UITextView) {
        
        //if the text field is empty or contains only whitespace, disable the send button
        let spacing = CharacterSet.whitespacesAndNewlines
        if !commentTextField.text.trimmingCharacters(in: spacing).isEmpty {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
        
        //increase the textview size if a new line is added
        //the textview increases only until its height reaches 130
        if textView.contentSize.height > textView.frame.size.height && textView.frame.height < 130 {
            
            //find the difference between the currently entered content height and the current textview height
            let difference = textView.contentSize.height - textView.frame.size.height
            
            //first, increase the y coordinate of the textview to allocate space for the height increase
            textView.frame.origin.y = textView.frame.origin.y - difference
            //then, increase the hight
            textView.frame.size.height = textView.contentSize.height
            
            //male the tableview smaller to accomodate for the changes
            if textView.contentSize.height + keyboard.height + commentYpos >= tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        } else if textView.contentSize.height < textView.frame.size.height {

            let difference = textView.frame.size.height - textView.contentSize.height
    
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            if textView.contentSize.height + keyboard.height + commentYpos > tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
    }

}
