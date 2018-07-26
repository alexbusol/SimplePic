//
//  UploadViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/26/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var publishButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disable and change the color of the publish button until the user
        //finishes creating a post
        publishButton.isEnabled = false
        publishButton.backgroundColor = .lightGray
        
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
        let zoomedImageSize = CGRect(x: 0, y: self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height * 1.5, width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        // frame of unzoomed (small) image
        let unzoomedImageSize = CGRect(x: 15, y: 15, width: self.view.frame.size.width / 4.5, height: self.view.frame.size.width / 4.5)
        
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
            })
            
        //return the image size to normal
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.userPicture.frame = unzoomedImageSize
                
                //unhide the background
                self.view.backgroundColor = .white
                self.titleTextView.alpha = 1
                self.publishButton.alpha = 1
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
        publishButton.frame = CGRect(x: 0, y: height / 1.09, width: width, height: width / 8)

    }

}
