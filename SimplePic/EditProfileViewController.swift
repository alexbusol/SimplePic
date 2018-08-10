//
//  EditProfileViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/26/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

class EditProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var webTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextView!
    
    @IBOutlet weak var privateTitle: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    
    var keyboardSize = CGRect() //holding the keyboard frame size
    
    
    //creating Picker View for gender selection
    var genderPicker : UIPickerView!
    var genders = ["Male", "Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //configure genderPicker
        genderPicker = UIPickerView()
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTextField.inputView = genderPicker
        
        //monitor keyboard state (show/hide)
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.showKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.hideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //tap to hide keyboard
        //adding the gesture recognizer to the view to hide the keyboard if any place on the screen is tapped
        let screenTapped = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.hideKeyboardAfterTap(_:)))
        screenTapped.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(screenTapped)
        
        //tap to choose image
        //adding gesture recognizer to the image view to open image picker/camera if the image is tapped
        let chooseAvatarTap = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.loadImage(_:)))
        chooseAvatarTap.numberOfTapsRequired = 1
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(chooseAvatarTap)
        
        configureLayout()
        getOldData()
        
        
    }
    
    //MARK: - Enabling ScrollView only if the keyboard is showing
    
  
    //hiding the keyboard after the screen was tapped
    @objc func hideKeyboardAfterTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //returning the window to the previous size
    @objc func hideKeyboard(_ notification: Notification) {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.scrollView.frame.size.height = self.view.frame.height
        })
    }
    
    @objc func showKeyboard(_ notification: Notification) {
        //setup keyboard size
        keyboardSize = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        //shrink the EditViewController if the keyboard is shown
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.contentSize.height = self.view.frame.size.height + self.keyboardSize.height / 2
        })
    }
    
    //MARK: - Updating the avatar
    //Opening the image picker if the user taps on the avatar.
    @objc func loadImage(_ recognizer: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        //allows the user to select a new avatar from the library and edit it
        //TO-DO: add an option to select from the camera
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    //place the new image into avatar image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        userImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    //setting UI layout constraints programatically
    func configureLayout() {
        //getting the width and height of the current screen
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        userImage.frame = CGRect(x: width - 68 - 10, y: 15, width: 68, height: 68)
        
        fullNameTextField.frame = CGRect(x: 10, y: userImage.frame.origin.y, width: width - userImage.frame.size.width - 30, height: 30)
        usernameTextField.frame = CGRect(x: 10, y: fullNameTextField.frame.origin.y + 40, width: width - userImage.frame.size.width - 30, height: 30)
        webTextField.frame = CGRect(x: 10, y: usernameTextField.frame.origin.y + 40, width: width - 20, height: 30)
        
        bioTextField.frame = CGRect(x: 10, y: webTextField.frame.origin.y + 40, width: width - 20, height: 60)
        bioTextField.layer.borderWidth = 1
        bioTextField.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).cgColor
        //rounding the text field a little bit
        bioTextField.layer.cornerRadius = bioTextField.frame.size.width / 50
        bioTextField.clipsToBounds = true
        
        emailTextField.frame = CGRect(x: 10, y: bioTextField.frame.origin.y + 100, width: width - 20, height: 30)
        phoneNumberTextField.frame = CGRect(x: 10, y: emailTextField.frame.origin.y + 40, width: width - 20, height: 30)
        genderTextField.frame = CGRect(x: 10, y: phoneNumberTextField.frame.origin.y + 40, width: width - 20, height: 30)
        
        privateTitle.frame = CGRect(x: 15, y: emailTextField.frame.origin.y - 30, width: width - 20, height: 30)
    }
    
    //when cancel is pressed
    @IBAction func cancelButton_pressed(_ sender: UIBarButtonItem) {
        self.view.endEditing(true) //dismiss the keyboard
        self.dismiss(animated: true, completion: nil) //dismiss the EditProfileViewController
    }
    
   
    
    //MARK: - Picker View Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //determining how many options are there in the Picker View
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2 //male + female
    }
    
    //returns the title of each the row selected in the pickerView
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    //when the user chooses an option from the picker view
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genders[row]
        self.view.endEditing(true)
    }
    
    //shows an alert with error and message that were passed
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(alertButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Show the user information before editing
    
    
    func getOldData() {
        
        //place the avatar received in the editorVC image view
        let avatarReceived = PFUser.current()?.object(forKey: "avatar") as! PFFile
        avatarReceived.getDataInBackground { (data, error) -> Void in
            self.userImage.image = UIImage(data: data!)
        }
        
        //place the other fields received into the respective text fields
        usernameTextField.text = PFUser.current()?.username
        fullNameTextField.text = PFUser.current()?.object(forKey: "FullName") as? String
        bioTextField.text = PFUser.current()?.object(forKey: "Bio") as? String
        webTextField.text = PFUser.current()?.object(forKey: "website") as? String
        
        emailTextField.text = PFUser.current()?.email
        phoneNumberTextField.text = PFUser.current()?.object(forKey: "PhoneNumber") as? String
        genderTextField.text = PFUser.current()?.object(forKey: "Gender") as? String
    }
    
    
    //MARK: - Make sure email and website fields containt correct data
    
    func validateEmail(_ email : String) -> Bool {
        //making sure that the email text field complies with the form user@email.domain
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}" //{num} -> no less than. [] -> specifies allowed symbols
        //checking if the email string is written according to regex rules
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        
        return result
    }
    
    func validateWeb (_ web : String) -> Bool {
        //making sure that the website textfield complies with the form www.website.domain
        
        //it's okay to have an empty website address
        if webTextField.text == "" {
            return true
        }
        
        let regex = "www.+[A-Z0-9a-z._%+-]+.[A-Za-z]{2}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    
    //MARK: - Save the updated user data on the server
    @IBAction func saveButton_pressed(_ sender: UIBarButtonItem) {
        //check the results of email and website validation
        
        //if email is incorrect
        if !validateEmail(emailTextField.text!) {
            showAlert(title: "Incorrect email", message: "Please make sure the email is in the form of: user@email.com")
            return
        }
        
        //if website address is incorrect
        if !validateWeb(webTextField.text!) {
            showAlert(title: "Incorrect website address", message: "Please make sure the website is in the form of: www.website.com")
            return
        }
        
        //save filled in information
        let userToUpdate = PFUser.current()!
        userToUpdate.username = usernameTextField.text?.lowercased()
        userToUpdate.email = emailTextField.text?.lowercased()
        userToUpdate["FullName"] = fullNameTextField.text?.lowercased()
        userToUpdate["website"] = webTextField.text?.lowercased()
        userToUpdate["Bio"] = bioTextField.text
        
        
        if phoneNumberTextField.text!.isEmpty {
            userToUpdate["PhoneNumber"] = ""
        } else {
            userToUpdate["PhoneNumber"] = phoneNumberTextField.text
        }
        
        if genderTextField.text!.isEmpty {
            userToUpdate["Gender"] = ""
        } else {
            userToUpdate["Genger"] = genderTextField.text
        }
        
        //compress the new avatar
        let avatarCompressed = UIImageJPEGRepresentation(userImage.image!, 0.5)
        let avatarToSend = PFFile(name: "userAvatar.jpg", data: avatarCompressed!)
        userToUpdate["avatar"] = avatarToSend
        
        //send the updated information to the server
        userToUpdate.saveInBackground (block: { (success, error) -> Void in
            if success{
                
                //hide the keyboard
                self.view.endEditing(true)
                
                //dismiss editViewController
                self.dismiss(animated: true, completion: nil)
                
                //send notification to homeVC to be reloaded
                //not used right now. done in ViewWillAppear() instead because it accomplishes more tasks at once
                //can add a catching "reload" function to receive the notification below
                //that's a different way of implementing reload functionality
                //NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
        
    }
}
