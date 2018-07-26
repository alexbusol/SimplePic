//
//  EditProfileViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/26/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func configureLayout() {
        
    }
    
    //when cancel is pressed
    @IBAction func cancelButton_pressed(_ sender: UIBarButtonItem) {
        self.view.endEditing(true) //dismiss the keyboard
        self.dismiss(animated: true, completion: nil) //dismiss the EditProfileViewController
    }
    
    //when save is pressed
    @IBAction func saveButton_pressed(_ sender: UIBarButtonItem) {
        
    }
}
