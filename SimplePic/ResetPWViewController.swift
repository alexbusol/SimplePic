//
//  resetPWViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/23/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

class ResetPWViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    //assigning constraints programmatically
    func configureLayout() {
        emailTextField.frame = CGRect(x: 10, y: 120, width: self.view.frame.size.width - 20, height: 30)
        
        resetButton.frame = CGRect(x: 20, y: emailTextField.frame.origin.y + 50, width: self.view.frame.size.width / 4, height: 30)
        resetButton.layer.cornerRadius = resetButton.frame.size.width / 20
        
        cancelButton.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: resetButton.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        cancelButton.layer.cornerRadius = cancelButton.frame.size.width / 20
    }

    @IBAction func resetPressed(_ sender: UIButton) {
        self.view.endEditing(true) //dismiss the keyboard if reset is pressed
        
        if let emailText = emailTextField.text {
            //if the email isnt empty, send a password reset request
            PFUser.requestPasswordResetForEmail(inBackground: emailText) { (success, error) -> Void in
                if success {
                    //tell the user to check the email to complete the reset
                    let alert = UIAlertController(title: "Confirm reset", message: "An email with a link has been sent to \(emailText). Click on the link to complete the password reset", preferredStyle: UIAlertControllerStyle.alert)
         
                    let alertButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(alertButton)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    print(error!.localizedDescription)
                }
            }
        } else {
            //email text field is empty
            let alert = UIAlertController(title: "Email is empty", message: "Please enter your email to reset the password", preferredStyle: .alert)
            let alertButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(alertButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func cancelPressed(_ sender: UIButton) {
        self.view.endEditing(true) 
        self.dismiss(animated: true, completion: nil)
    }
}
