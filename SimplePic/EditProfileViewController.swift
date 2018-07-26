//
//  EditProfileViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/26/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

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
        
        configureLayout()
        
        
    }
    
    
    
    //setting layout constraints programatically
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
    
    //when save is pressed
    @IBAction func saveButton_pressed(_ sender: UIBarButtonItem) {
        
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
}
