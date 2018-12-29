//
//  NotificationsViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 11/2/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//


import UIKit
import Parse


class NotificationsViewController: UITableViewController {
    
    var usernameArray = [String]()
    var avatarArray = [PFFile]()
    var typeArray = [String]()
    var dateArray = [Date?]()
    var uuidArray = [String]()
    var ownerArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        //display page title at the top
        self.navigationItem.title = "NOTIFICATIONS"
        
        // request notifications
        let query = PFQuery(className: "notifications")
        query.whereKey("to", equalTo: PFUser.current()!.username!)
        query.limit = 30
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                //clean up the storage arrays
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avatarArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.ownerArray.removeAll(keepingCapacity: false)
                
                //populate the storage structures with info from the server
                for object in objects! {
                    self.usernameArray.append(object.object(forKey: "by") as! String)
                    self.avatarArray.append(object.object(forKey: "avatar") as! PFFile)
                    self.typeArray.append(object.object(forKey: "notification_type") as! String)
                    self.dateArray.append(object.createdAt)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                    self.ownerArray.append(object.object(forKey: "commentOwner") as! String)
                    
                    //change notification status to checked when read
                    object["seen"] = "yes"
                    object.saveEventually()
                }
                
                // reload tableView to show received data
                self.tableView.reloadData()
            }
        })
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    
    //configure table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NotificationCell
        
        //fill the cell with data from the server
        cell.usernameButton.setTitle(usernameArray[indexPath.row], for: UIControlState())
        avatarArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.userImage.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        //calculate post date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
        
        if difference.second! <= 0 {
            cell.dateLabel.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.dateLabel.text = "\(String(describing: difference.second))s."
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.dateLabel.text = "\(String(describing: difference.minute))m."
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLabel.text = "\(String(describing: difference.hour))h."
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.dateLabel.text = "\(String(describing: difference.day))d."
        }
        if difference.weekOfMonth! > 0 {
            cell.dateLabel.text = "\(String(describing: difference.weekOfMonth))w."
        }
        
        //decide what notification information to display
        if typeArray[indexPath.row] == "mention" {
            cell.informationLabel.text = " has mentioned you."
        }
        if typeArray[indexPath.row] == "comment" {
            cell.informationLabel.text = " has left a comment on your post."
        }
        if typeArray[indexPath.row] == "follow" {
            cell.informationLabel.text = " is now following you."
        }
        if typeArray[indexPath.row] == "like" {
            cell.informationLabel.text = " liked your post."
        }
        
        
        cell.usernameButton.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    
    @IBAction func usernameButton_pressed(_ sender: UIButton) {
        
        let i = sender.layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! NotificationCell
        
        //if the username if the user's own, go to home page. Otherwise, go to the guest view.
        if cell.usernameButton.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestUsername.append(cell.usernameButton.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! GuestViewController
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    //MARK: - Define actions for clicking on different notifications
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! NotificationCell
        
        
        //clicking on mentions notifications
        if cell.informationLabel.text == " has mentioned you." {
            
            commentUUID.append(uuidArray[indexPath.row])
            commentOwner.append(ownerArray[indexPath.row])
            
            //redirect to the comment view 
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            self.navigationController?.pushViewController(comment, animated: true)
        }
        
        
        //clicking on comment notifications
        if cell.informationLabel.text == " has left a comment on your post." {
            
            commentUUID.append(uuidArray[indexPath.row])
            commentOwner.append(ownerArray[indexPath.row])
            
            //redirect to the comment view
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            self.navigationController?.pushViewController(comment, animated: true)
        }
        
        
        //clicking on following notifications
        if cell.informationLabel.text == " is now following you." {
            
            guestUsername.append(cell.usernameButton.titleLabel!.text!)
            
            //redirect to the follower's page
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestViewController") as! GuestViewController
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
        
        //clicking on like notifications
        if cell.informationLabel.text == "liked your post." {
            
            postToLoadUUID.append(uuidArray[indexPath.row])
            
            //redirect to the liked post
            let post = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
            self.navigationController?.pushViewController(post, animated: true)
        }
        
    }
    
}
