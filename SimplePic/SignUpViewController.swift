//
//  SignUpViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/23/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse //for communicating with the server

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //MARK: - Setting up outlets
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var usernameTextfField: UITextField!
    @IBOutlet weak var passwordTextfField: UITextField!
    @IBOutlet weak var repeatPWTextfField: UITextField!
    @IBOutlet weak var fullNameTextfField: UITextField!
    @IBOutlet weak var bioTextfField: UITextField!
    @IBOutlet weak var websiteTextfField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: - Setting up scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    var scrollViewHeight : CGFloat = 0 //reseting scroll view height after hiding the keyboard
    
    var keyboardSize = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    func configureLayout() {
        
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height
        )
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
        
        //calling these methods when the keyboard is shown/hidden
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.showKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.hideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //adding tap recognizer to hide the keyboard if any place of the screen is tapped
        let screenTapped = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.hideKeyboardAfterTap(_:)))
        screenTapped.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true //allowing taps to be registered by the VC
        self.view.addGestureRecognizer(screenTapped)
        
        //when user clicks on the avatar
        let addAvatar = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.loadImage(_:)))
        addAvatar.numberOfTapsRequired = 1
        userAvatar.isUserInteractionEnabled = true
        userAvatar.addGestureRecognizer(addAvatar)
        
        //Assigning constraints programmatically
        //these statements specify the elements' position in relation to screen borders, as well as to other elements
        userAvatar.frame = CGRect(x: self.view.frame.size.width / 2 - 40, y: 40, width: 80, height: 80)
        usernameTextfField.frame = CGRect(x: 10, y: userAvatar.frame.origin.y + 90, width: self.view.frame.size.width - 20, height: 30)
        passwordTextfField.frame = CGRect(x: 10, y: usernameTextfField.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        repeatPWTextfField.frame = CGRect(x: 10, y: passwordTextfField.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        userEmailTextField.frame = CGRect(x: 10, y: repeatPWTextfField.frame.origin.y + 60, width: self.view.frame.size.width - 20, height: 30)
        fullNameTextfField.frame = CGRect(x: 10, y: userEmailTextField.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        bioTextfField.frame = CGRect(x: 10, y: fullNameTextfField.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        websiteTextfField.frame = CGRect(x: 10, y: bioTextfField.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        
        signUpButton.frame = CGRect(x: 20, y: websiteTextfField.frame.origin.y + 50, width: self.view.frame.size.width / 4, height: 30)
        signUpButton.layer.cornerRadius = signUpButton.frame.size.width / 20
        
        cancelButton.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: signUpButton.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        cancelButton.layer.cornerRadius = cancelButton.frame.size.width / 20
    }
    
    //MARK: - Handiling the keyboard
    //scrolling is only available when keyboard is shown
    @objc func showKeyboard(_ notification: NSNotification) {
        //setting keyboard size
        keyboardSize = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        // move the UI upward when the keyboard is activated
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboardSize.height
        })
    }
    
    @objc func hideKeyboard(_ notification: Notification) {
       //move the scroll view downward after the keyboard is is dismissed
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.scrollView.frame.size.height = self.view.frame.height
        })
    }
    
    @objc func hideKeyboardAfterTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: - selecting user image from the gallery when avatar is pressed
    @objc func loadImage(_ recognizer: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true //allows the user to edit the image before selecting
        present(imagePicker, animated: true, completion: nil)
    }
    
    //after the image is selected, place it in the image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        userAvatar.image = info[UIImagePickerControllerEditedImage] as? UIImage
        //round the selected image
        userAvatar.layer.cornerRadius = userAvatar.frame.size.width / 2
        userAvatar.clipsToBounds = true
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Button handlers
    @IBAction func signUpClicked(_ sender: UIButton) {
        print("Sign up pressed")
        //dismiss keyboard when sign up is pressed
        self.view.endEditing(true)
        
        
        //show an alert if some of required fields arent filled out
        if  (usernameTextfField.text!.isEmpty || passwordTextfField.text!.isEmpty || repeatPWTextfField.text!.isEmpty || userEmailTextField.text!.isEmpty || bioTextfField.text!.isEmpty || fullNameTextfField.text!.isEmpty) {
            let alert = UIAlertController(title: "Error", message: "Please fill out all required text fields", preferredStyle: UIAlertControllerStyle.alert)
            let alertButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(alertButton)
            self.present(alert, animated: true, completion: nil)
        }
        
        //show an alert if the two passwords dont match
        if passwordTextfField.text != repeatPWTextfField.text {
            let alert = UIAlertController(title: "Passwords don't match", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let alertButton = UIAlertAction(title: "Try again", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(alertButton)
            self.present(alert, animated: true, completion: nil)
        }
        
        //MARK: - Recording the new user info on the server using Parse
        let newUser = PFUser()
        newUser.username = usernameTextfField.text?.lowercased()
        newUser.email = userEmailTextField.text?.lowercased()
        newUser.password = passwordTextfField.text
        newUser["FullName"] = fullNameTextfField.text?.lowercased()
        newUser["Bio"] = bioTextfField.text?.lowercased()
        
        //adding user's personal website if it was entered
        if let website = websiteTextfField.text {
            newUser["website"] = website
        }
        //this information isn't required, but users will be able to edit it once they go to "edit profile" in their account
        newUser["PhoneNumber"] = ""
        newUser["Gender"] = ""
        //convert the selected avatar to JPEG and send it to the server
        let avatar = UIImageJPEGRepresentation(userAvatar.image!, 0.5)
        let avatarToSend = PFFile(name: "Avatar.jpg", data: avatar!)
        newUser["avatar"] = avatarToSend
        
        //MARK: - Send the recorded data to the server
        newUser.signUpInBackground { (success, error) -> Void in
            if success {
                print("new user was registered")
                
                // IMPORTANT: memorize the user, so that he doesnt have to login again after relaunching the app
                UserDefaults.standard.set(newUser.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // use the login method in App delegate to login the user
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate //share app delegate with the current view controller
                appDelegate.login()
                
            } else {
                //tell the user that registration failed
                let alert = UIAlertController(title: "Registration Failed", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let alertButton = UIAlertAction(title: "Try again", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(alertButton)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    @IBAction func cancelClicked(_ sender: UIButton) {
        print("Cancel pressed")
        self.dismiss(animated: true, completion: nil) //returning back to the welcome screen if cancel is pressed
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
