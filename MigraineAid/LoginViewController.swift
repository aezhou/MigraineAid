//
//  LoginViewController.swift
//  MigraineAid
//
//  Created by Amanda Zhou on 11/13/15.
//  Copyright © 2015 Amanda Zhou. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        usernameTextField.delegate = self
        usernameTextField.returnKeyType = UIReturnKeyType.Next
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = UIReturnKeyType.Send
    }
    
    @IBAction func signInTapped(sender: AnyObject) {
        login()
    }
    
    func login() {
        let username = self.usernameTextField.text!
        let password = self.passwordTextField.text!
        
        var alertController: UIAlertController
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        // Validate the text fields
        if username.characters.count < 5 {
            alertController = UIAlertController(title: "Invalid", message: "Username must be greater than 5 characters", preferredStyle: .Alert)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else if password.characters.count < 8 {
            
            alertController = UIAlertController(title: "Invalid", message: "Password must be greater than 8 characters", preferredStyle: .Alert)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .Alert)
            
            // Send a request to login
            PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                
                if ((user) != nil) {                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home")
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
//                        self.presentViewController(viewController, animated: true, completion: nil)
                    })
                    
                } else {
                    alertController = UIAlertController(title: "Error", message: "\(error!.localizedDescription)", preferredStyle: .Alert)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.passwordTextField {
            textField.resignFirstResponder()
            
            login()
        } else if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "/n" {
            textField.resignFirstResponder()
            return false
        } else {
            return true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
