//
//  SignUpViewController.swift
//  MigraineAid
//
//  Created by Amanda Zhou on 11/13/15.
//  Copyright © 2015 Amanda Zhou. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        emailTextField.delegate = self
        emailTextField.returnKeyType = .Next
        usernameTextField.delegate = self
        usernameTextField.returnKeyType = .Next
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = .Send
        
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
    }
    
    @IBAction func signUpTapped(sender: AnyObject) {
        createAccount()
    }
    
    func createAccount() {
        let username = self.usernameTextField.text!
        let password = self.passwordTextField.text!
        let email = self.emailTextField.text!
        let finalEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        
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
            
        } else if email.characters.count < 8 {
            
            alertController = UIAlertController(title: "Invalid", message: "Please enter a valid email address", preferredStyle: .Alert)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            let newUser = PFUser()
            
            newUser.username = username
            newUser.password = password
            newUser.email = finalEmail
            
            alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .Alert)
            // Sign up the user asynchronously
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil) {
                    
                    alertController = UIAlertController(title: "Error", message: "\(error!.localizedDescription)", preferredStyle: .Alert)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let tmpController :UIViewController! = self.presentingViewController;
                        
                        self.dismissViewControllerAnimated(false, completion: {()->Void in
                            tmpController.dismissViewControllerAnimated(false, completion: nil);
                        });
                    })
                }
            })
        }
    }
    
    @IBAction func gotoLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.passwordTextField {
            textField.resignFirstResponder()
            createAccount()
        } else if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.emailTextField {
            self.usernameTextField.becomeFirstResponder()
        }
        return true
    }
    
    func dismissKeyboard() {
        self.emailTextField.resignFirstResponder()
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
