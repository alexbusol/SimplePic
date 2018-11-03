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

class CommentViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

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
    var avatarArray = [PFFile]()
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
        tableView.dataSource = self
     
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
        loadComments()
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

        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - self.navigationController!.navigationBar.frame.size.height - 40)
        tableView.estimatedRowHeight = width / 5.333
        tableView.rowHeight = UITableViewAutomaticDimension

        commentTextField.frame = CGRect(x: 10, y: tableView.frame.size.height + height / 56.8, width: width / 1.306, height: 33)
        commentTextField.layer.cornerRadius = commentTextField.frame.size.width / 50

        sendButton.frame = CGRect(x: commentTextField.frame.origin.x + commentTextField.frame.size.width + width / 32, y: commentTextField.frame.origin.y, width: width - (commentTextField.frame.origin.x + commentTextField.frame.size.width) - (width / 32) * 2, height: commentTextField.frame.size.height)

        tableViewHeight = tableView.frame.size.height+150
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
    
    //return the number of rows our table view will show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: - Filling the comment cell with information
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commentCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommentCell
        
        //populating the comment cell with user information
        commentCell.usernameButton.setTitle(usernameArray[indexPath.row], for: UIControlState())
        commentCell.usernameButton.sizeToFit()
        commentCell.commentLabel.text = commentArray[indexPath.row]
        avatarArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                commentCell.userAvatar.image = UIImage(data: data!)
            } else {
                print(String(describing: error?.localizedDescription))
            }
        }
        
        //calculating the time since a comment was posted
        let commentPosted = dateArray[indexPath.row]
        let currentDate = Date()
        let timeComponents : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let timeDifference = (Calendar.current as NSCalendar).components(timeComponents, from: commentPosted!, to: currentDate, options: [])
        
        if timeDifference.second! <= 0 {
            commentCell.commentDate.text = "now"
        }
        if timeDifference.second! > 0 && timeDifference.minute! == 0 {
            commentCell.commentDate.text = "\(String(describing: timeDifference.second!))s ago"
        }
        if timeDifference.minute! > 0 && timeDifference.hour! == 0 {
            commentCell.commentDate.text = "\(String(describing: timeDifference.minute!))m ago"
        }
        if timeDifference.hour! > 0 && timeDifference.day! == 0 {
            commentCell.commentDate.text = "\(String(describing: timeDifference.hour!))h ago"
        }
        if timeDifference.day! > 0 && timeDifference.weekOfMonth! == 0 {
            commentCell.commentDate.text = "\(String(describing: timeDifference.day!))d ago"
        }
        if timeDifference.weekOfMonth! > 0 {
            commentCell.commentDate.text = "\(String(describing: timeDifference.weekOfMonth!))w ago"
        }
        
        //implementing @ mentions
        commentCell.commentLabel.userHandleLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.dropFirst()) //drop the @ symbol
            
            //if the @mention is referring to the current user, go to the homescreen view controller
            if mention.lowercased() == PFUser.current()?.username {
                let goHome = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
                self.navigationController?.pushViewController(goHome, animated: true)
            } else {
                //else, direct the user to the profile mentioned
                guestUsername.append(mention.lowercased())
                let goGuest = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! GuestViewController
                self.navigationController?.pushViewController(goGuest, animated: true)
            }
        }
        
        //if a hashtag in the comment body is tapped
        
        commentCell.commentLabel.hashtagLinkTapHandler = { label, handle, range in
            var hashtag = handle
            hashtag = String(hashtag.dropFirst())
            
            //storing the hashtag in the storage array inside Hashtag View Controller
            //will be used to display all the relevant info
            hashtagArray.append(hashtag.lowercased())
            
            //sending the user to the HashtagViewController
            let goHashtag = self.storyboard?.instantiateViewController(withIdentifier: "HashtagViewController") as! HashtagViewController
            self.navigationController?.pushViewController(goHashtag, animated: true)
        }
        
        //getting current comment cell username index
        commentCell.usernameButton.layer.setValue(indexPath, forKey: "index")
        return commentCell
        
        
    }
    
    //MARK: - Load the post comments from the database
    func loadComments() {
        
        //count the total number of comments for the post in the database
        let commentQuery = PFQuery(className: "comments")
        commentQuery.whereKey("to", equalTo: commentUUID.last!)
        commentQuery.countObjectsInBackground (block: { (count, error) -> Void in
            
            //enable 'pull to refresh' functionality if there are more posts than the current page size
            //this way, 'loadAdditionalComments' will be called when the user pulls down
            print(self.pageSize)
            print(count)
            if self.pageSize < count {
                self.refresh.addTarget(self, action: #selector(CommentViewController.loadAdditionalComments), for: UIControlEvents.valueChanged)
                self.tableView.addSubview(self.refresh)
            }
            
            //get the most recent posts for the page size
            let query = PFQuery(className: "comments")
            query.whereKey("to", equalTo: commentUUID.last!)
            query.limit = Int(self.pageSize)
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    print("went to if")
                    //clean he storage arrays
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.avatarArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    //place the CommentCell objects in the storage arrays
                    for object in objects! {
                        self.usernameArray.append(object.value(forKey: "username") as! String)
                        self.avatarArray.append(object.value(forKey: "avatar") as! PFFile)
                        self.commentArray.append(object.value(forKey: "comment") as! String)
                        self.dateArray.append(object.createdAt)
                        self.tableView.reloadData()
                        
                        //scroll to the bottom of the comments that were loaded
                        //OPTIONAL. MAYBE BETTER WITHOUT IT
//                        self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
                        
                        //load more comments when reaching the bottom and there are more comments in the DB
                        if self.pageSize < count {
                            self.loadAdditionalComments()
                        }
                    }
                } else {
                    print(String(describing: error?.localizedDescription))
                }
            })
        })
    }
    
    @objc func loadAdditionalComments() {
        //count the total number of comments
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentUUID.last!)
        countQuery.countObjectsInBackground (block: { (count, error) -> Void in
            
          
            self.refresh.endRefreshing()
            
            //if there are more comments left to display, load more
            if self.pageSize < count {
                
                //increase the page size
                self.pageSize = self.pageSize + 15
                
                //get the next pagesize comments from the server
                let query = PFQuery(className: "comments")
                query.whereKey("to", equalTo: commentUUID.last!)
                query.limit = Int(self.pageSize)
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        //clean the previous comments fromt the storage array
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avatarArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        
                        // find related objects
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avatarArray.append(object.object(forKey: "avatar") as! PFFile)
                            self.commentArray.append(object.object(forKey: "comment") as! String)
                            self.dateArray.append(object.createdAt)
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error?.localizedDescription ?? String())
                    }
                })
            }
            
        })
        
    }

    
    //MARK: - Placing the comment in the CommentView and sending it to the server
    @IBAction func sendButton_pressed(_ sender: UIButton) {
        //Place the newly created comment in the Table View
        usernameArray.append(PFUser.current()!.username!)
        avatarArray.append(PFUser.current()?.object(forKey: "avatar") as! PFFile)
        dateArray.append(Date())
        commentArray.append(commentTextField.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        tableView.reloadData()
//        print("Comment was pressed")
        //send the comment to the server
        let commentToSend = PFObject(className: "comments")
        commentToSend["to"] = commentUUID.last
        commentToSend["username"] = PFUser.current()?.username
        commentToSend["avatar"] = PFUser.current()?.value(forKey: "avatar")
        commentToSend["comment"] = commentTextField.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        commentToSend.saveEventually()
        
        //MARK: - if there's a hashtag in the comment, record it in the database
        let commentWords : [String] = commentTextField.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        //parse the comment text
        for var word in commentWords {
            
            //make sure that the current word is a hashtag
            if word.hasPrefix("#") {
                
                //remove the # symbol from the word
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                //save the new hashtag in the database
                let hashtag = PFObject(className: "hashtags")
                hashtag["toComment"] = commentUUID.last
                hashtag["byUser"] = PFUser.current()?.username
                hashtag["hashtag"] = word.lowercased()
                hashtag["comment"] = commentTextField.text
                
                hashtag.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
        //MARK: - Send a notification to the user when @mention is used
        var mentionCreated = Bool()
        
        for var word in commentWords {
            
            //check if @ was used before a word
            if word.hasPrefix("@") {
                
                //remove punctuation characters and other extra symbols
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                //writing information about new @mention to the database
                let notificationObject = PFObject(className: "notifications")
                notificationObject["by"] = PFUser.current()?.username
                notificationObject["to"] = word
                notificationObject["avatar"] = PFUser.current()?.object(forKey: "avatar") as! PFFile
                notificationObject["commentOwner"] = commentOwner.last
                notificationObject["uuid"] = commentUUID.last
                notificationObject["notification_type"] = "mention"
                notificationObject["seen"] = "no"
                notificationObject.saveEventually()
                mentionCreated = true
            }
        }
        
        //MARK: - Send a notification to the user if another user left a comment under his post
        
        if commentOwner.last != PFUser.current()?.username && mentionCreated == false {
            let notificationObject = PFObject(className: "notifications")
            notificationObject["by"] = PFUser.current()?.username
            notificationObject["avatar"] = PFUser.current()?.object(forKey: "avatar") as! PFFile
            notificationObject["to"] = commentOwner.last
            notificationObject["commentOwner"] = commentOwner.last
            notificationObject["uuid"] = commentUUID.last
            notificationObject["notification_type"] = "comment"
            notificationObject["seen"] = "no"
            notificationObject.saveEventually()
        }

        //scroll to bottom of the comment view
        self.tableView.scrollToRow(at: IndexPath(item: commentArray.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
        
        //reset the CommentView to default values
        sendButton.isEnabled = false
        commentTextField.text = ""
        commentTextField.frame.size.height = commentHeight
        commentTextField.frame.origin.y = sendButton.frame.origin.y
        tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTextField.frame.size.height + self.commentHeight
        
    }
    
    //handling clikcing on the username
    @IBAction func usernameButton_pressed(_ sender: UIButton) {
    
        //get the index of the current username in the CommentCell
        let i = sender.layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! CommentCell
        
        //send the user to either home or guest view, depending on the comment author
        if cell.usernameButton.titleLabel?.text == PFUser.current()?.username {
            let goHome = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
            self.navigationController?.pushViewController(goHome, animated: true)
        } else {
            guestUsername.append(cell.usernameButton.titleLabel!.text!)
            let goGuest = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! GuestViewController
            self.navigationController?.pushViewController(goGuest, animated: true)
        }
    }
    
    
    //MARK: - Implement 'swipe left to see more actions' for comments
    
    //make table cells editable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let commentCell = tableView.cellForRow(at: indexPath) as! CommentCell
        
        //implementing a 'delete' function
        let delete = UITableViewRowAction(style: .normal, title: "delete") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            //if delete is selected, delete it from the server
            
            //query the database for the comment
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: commentUUID.last!)
            commentQuery.whereKey("comment", equalTo: commentCell.commentLabel.text!)
            commentQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    //delete the results of the query
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            //removing the comment's hashtags from the database if the comment is deleted
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("toComment", equalTo: commentUUID.last!)
            hashtagQuery.whereKey("byUser", equalTo: commentCell.usernameButton.titleLabel!.text!)
            hashtagQuery.whereKey("comment", equalTo: commentCell.commentLabel.text!)
            hashtagQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                for object in objects! {
                    object.deleteEventually()
                }
            })
            
            
            //remove the existing mentions from the database if the comment is deleted
            let notificationQuery = PFQuery(className: "notifications")
            notificationQuery.whereKey("by", equalTo: commentCell.usernameButton.titleLabel!.text!)
            notificationQuery.whereKey("to", equalTo: commentOwner.last!)
            notificationQuery.whereKey("uuid", equalTo: commentUUID.last!)
            notificationQuery.whereKey("notification_type", containedIn: ["comment", "mention"])
            notificationQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            //delete the comment from the table view with animation
            self.commentArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.usernameArray.remove(at: indexPath.row)
            self.avatarArray.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        
        //implementing a 'reply' function
        let reply = UITableViewRowAction(style: .normal, title: "reply") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            //change the existing comment to include the username int
            self.commentTextField.text = "\(self.commentTextField.text + "@" + self.usernameArray[indexPath.row] + " ")"
            self.sendButton.isEnabled = true

            tableView.setEditing(false, animated: true)
        }
        
        //implementing 'report the comment'
        let report = UITableViewRowAction(style: .normal, title: "report") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            //record the complaint in the database
            let complaint = PFObject(className: "complaint")
            complaint["by"] = PFUser.current()?.username
            complaint["about"] = commentCell.commentLabel.text
            complaint["owner"] = commentCell.usernameButton.titleLabel?.text
            complaint.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.showAlert(title: "Report successful", message: "Thank You! We will investigate your complaint")
                } else {
                    self.showAlert(title: "Unable to report the comment", message: error!.localizedDescription)
                }
            })

            tableView.setEditing(false, animated: true)
        }
        
        //show different options depending on the user
        //user's own comment
        if commentCell.usernameButton.titleLabel?.text == PFUser.current()?.username {
            return [delete, reply]
        }
            
        //somebody else's comment under the current user's post
        else if commentOwner.last == PFUser.current()?.username {
            return [delete, reply, report]
        }
            
        //somebody else's comment under another user's post
        else  {
            return [reply, report]
        }
        
        
        
    }
    
    //shows an alert with error and message that were passed
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(alertButton)
        self.present(alert, animated: true, completion: nil)
    }
}
