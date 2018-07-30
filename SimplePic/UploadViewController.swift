//
//  UploadViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/26/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disable and change the color of the publish button until the user
        //finishes creating a post
        publishButton.isEnabled = false
        publishButton.backgroundColor = .lightGray
        
        
        //hide the remove button if there's no image uploaded
        removeButton.isHidden = true
        
        //set a default image if no post image is uploaded
        //can change to something better later
        //now just a placeholder image
        userPicture.image = UIImage(named: "postbg.jpg")
        
        //hiding the keyboard if the screen is tapped
        let screenTapped = UITapGestureRecognizer(target: self, action: #selector(UploadViewController.hideKeyboardTap))
        screenTapped.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(screenTapped)
        
        let pictureTapped = UITapGestureRecognizer(target: self, action: #selector(UploadViewController.selectImage))
        pictureTapped.numberOfTapsRequired = 1
        userPicture.isUserInteractionEnabled = true
        userPicture.addGestureRecognizer(pictureTapped)
        configureLayout()
    }
    
    
    //dismisses the keyboard when the screen is tapped
    @objc func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    //allows the user to pick an image for the post
    @objc func selectImage() {
        //TODO: make an option to choose an image from camera as well
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary //add a camera option as well
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    //places the picked image into the post imageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        userPicture.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        //enable the publish button when the picture is successfully selected
        publishButton.isEnabled = true
        publishButton.backgroundColor = .blue
        
        //show the remove button now that the picture is uploaded
        removeButton.isHidden = false
        //allow the user to zoom the image by tapping on the image view in the UploadVC after uploading the image
        //if the image is tapped again, the frame size returns to normal
        let zoomImage = UITapGestureRecognizer(target: self,  action: #selector(UploadViewController.zoomImage))
        zoomImage.numberOfTapsRequired = 1
        userPicture.isUserInteractionEnabled = true
        userPicture.addGestureRecognizer(zoomImage)
    }
    
    //handles image zoom
    @objc func zoomImage() {
        
        //the app change the picture frame sizes depending on if it's zoomed/unzoomed
        let zoomedImageSize = CGRect(x: 0, y: self.view.center.y - self.view.center.x, width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        // frame of unzoomed (small) image
        let unzoomedImageSize = CGRect(x: 15, y: self.navigationController!.navigationBar.frame.size.height + 35, width: self.view.frame.size.width / 4.5, height: self.view.frame.size.width / 4.5)
        
        if userPicture.frame == unzoomedImageSize {
            //increase the size of the picture with animation
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                //assignt the new size to the picture frame
                self.userPicture.frame = zoomedImageSize
                
                //hide the objects in the background
                //TODO: maybe make semi-transparent?
                self.view.backgroundColor = .black
                self.titleTextView.alpha = 0
                self.publishButton.alpha = 0
                self.removeButton.alpha = 0
            })
            
        //return the image size to normal
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.userPicture.frame = unzoomedImageSize
                
                //unhide the background
                self.view.backgroundColor = .white
                self.titleTextView.alpha = 1
                self.publishButton.alpha = 1
                self.removeButton.alpha = 1
            })
        }
    }
    
    //setting UI layout constraints programatically
    func configureLayout() {
        //getting the width and height of the current screen
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        userPicture.frame = CGRect(x: 15, y: 15, width: width / 4.5, height: width / 4.5)
        titleTextView.frame = CGRect(x: userPicture.frame.size.width + 25, y: userPicture.frame.origin.y, width: width / 1.488, height: userPicture.frame.size.height)
        publishButton.frame = CGRect(x: 0, y: height / 1.29, width: width, height: width / 8)
        removeButton.frame = CGRect(x: userPicture.frame.origin.x, y: userPicture.frame.origin.y + userPicture.frame.size.height, width: userPicture.frame.size.width, height: 20)


    }

    @IBAction func publishButton_pressed(_ sender: UIButton) {
        //dismiss the keyboard
        self.view.endEditing(true)
        
        //prepare the the post for sending to the database
        //filling the columns of the POSTS class in the database
        let object = PFObject(className: "posts")
        object["username"] = PFUser.current()!.username
        object["avatar"] = PFUser.current()!.value(forKey: "avatar") as! PFFile
        
        let uuid = UUID().uuidString
        object["uuid"] = "\(PFUser.current()!.username!) \(uuid)"
        
        //adding some text under the image if the user has entered any
        //title column in the POSTS class of the database holds the text that user adds under the posted image
        if titleTextView.text.isEmpty {
            object["title"] = ""
        } else {
            //removing any extra whitespace
            object["title"] = titleTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        //send the user picked image to the server with compressiong
        let imageToPost = UIImageJPEGRepresentation(userPicture.image!, 0.5)
        let imageFile = PFFile(name: "post.jpg", data: imageToPost!)
        object["pic"] = imageFile
        
        
        //save the new post on the server in the POSTS class
        object.saveInBackground (block: { (success, error) -> Void in
            if error == nil {
                
                //send notification to be received in HomeScreenViewController
                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadedPost"), object: nil)
                
                //switch to the tab bar option 0 (home screen view controller)
                self.tabBarController!.selectedIndex = 0
                
                //reset UploadViewController to its default state
                self.viewDidLoad()
                self.titleTextView.text = ""
            }
        })
    }
    
    //allowing the user to remove the image from the post image view and choose another
    @IBAction func removeButton_pressed(_ sender: UIButton) {
        //remove the uploaded post image
        //calling view did load here resets the UploadViewController to its default view
        viewDidLoad()
    }
    
}
