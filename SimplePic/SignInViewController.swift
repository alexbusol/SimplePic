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
    
    
    @IBAction func signInClicked(_ sender: UIButton) {
        print("clicked sign in")
        
        self.view.endEditing(true) //dismiss the keyboard when sign in is pressed
        
        //show an alert if the login fields are empty
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            let alert = UIAlertController(title: "Login Error", message: "Login or password fields are empty", preferredStyle: .alert)
            let alertButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(alertButton)
            self.present(alert, animated: true, completion: nil)
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
                
                //Login unsuccessful. Show an alert
                let alert = UIAlertController(title: "Login Error", message: error!.localizedDescription, preferredStyle: .alert)
                let alertButton = UIAlertAction(title: "Try again", style: .cancel, handler: nil)
                alert.addAction(alertButton)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
