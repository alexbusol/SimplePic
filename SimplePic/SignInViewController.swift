//
//  signInViewController.swift
//  SimplePic
//
//  Created by Alex Busol on 7/23/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

class SignInViewController: UIViewController {

    //MARK: - Setting up buttons and textfields
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPWButton: UIButton!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBAction func signInClicked(_ sender: UIButton) {
        print("clicked sign in")
        
        self.view.endEditing(true) //dismiss the keyboard when sign in is pressed
        
        //show an alert if the login fields are empty
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            showAlert(title: "Login Error", message: "Login or password fields are empty")
        }
        
        //MARK: - Login using Parse. We pass in the username and password textfields' contents.
        //The server will check if the username and password are correct
        PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!) { (user, error) -> Void in
            if error == nil {
                print("Sign in successful")
                //If the login was successful, remember the user
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                //call the login method from App Delegate to present the tab controller
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                
            } else {
                print("login error")
                self.showAlert(title: "Login Error", message: "Unable to login. Please verify your username and password and try again.")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    func configureLayout() {
        
        //Assigning constraints programmatically
        welcomeLabel.frame = CGRect(x: 10, y: 80, width: self.view.frame.size.width - 20, height: 111)
        usernameTextField.frame = CGRect(x: 10, y: welcomeLabel.frame.origin.y + 120, width: self.view.frame.size.width - 20, height: 30)
        passwordTextField.frame = CGRect(x: 10, y: usernameTextField.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        forgotPWButton.frame = CGRect(x: 10, y: passwordTextField.frame.origin.y + 30, width: self.view.frame.size.width - 20, height: 30)
        
        signInButton.frame = CGRect(x: 20, y: forgotPWButton.frame.origin.y + 40, width: self.view.frame.size.width / 4, height: 30)
        signInButton.layer.cornerRadius = signInButton.frame.size.width / 20
        
        signUpButton.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: signInButton.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        signUpButton.layer.cornerRadius = signUpButton.frame.size.width / 20
        
        
        let background = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        background.image = UIImage(named: "bg.jpg")
        background.layer.zPosition = -1
        self.view.addSubview(background)
    }
    
    //shows an alert with error and message that were passed
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(alertButton)
        self.present(alert, animated: true, completion: nil)
    }

}
