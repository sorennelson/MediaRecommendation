//
//  CreateUserViewController.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 5/2/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class AuthenticationViewController: NSViewController {
    
    @IBOutlet var usernameTextField: NSTextField!
    @IBOutlet var passwordTextField: NSSecureTextField!
        
    override func dismiss(_ sender: Any?) {
        //        TODO: reload main view
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        if !isValidUsernamePassword() {
            self.showInvalidEmailPasswordNotification()
            return
        }
        
        UserController.sharedInstance.createUser(username: usernameTextField.stringValue,
                                                 password: passwordTextField.stringValue) { (success, error) in
            if !success {
                self.showErrorCreatingAccountNotification(error!)
            } else {
                self.showSuccessCreatingAccountNotification()
                self.presentingViewController?.dismiss(self)
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if !isValidUsernamePassword() {
            self.showInvalidEmailPasswordNotification()
            return
        }
        
        UserController.sharedInstance.login(username: usernameTextField.stringValue,
                                            password: passwordTextField.stringValue) { (success, error) in
            if !success {
                self.showErrorCreatingAccountNotification(error!)
                
            } else {
                self.showSuccessLoggingInNotification()
                self.presentingViewController?.dismiss(self)
            }
        }
    }
    
    func isValidUsernamePassword() -> Bool {
        if usernameTextField.stringValue.isEmpty == false
            && passwordTextField.stringValue.isEmpty == false {
            return true
        }
        return false
    }
    
    func showInvalidEmailPasswordNotification() {
        print("Bad Email / Password")
//            TODO:
    }
    
    func showErrorCreatingAccountNotification(_ error: String) {
        print("Error creating Account")
        //        TODO:
    }
    
    func showErrorLoggingInNotification(_ error: String) {
        print("Error creating Account")
        //        TODO:
    }
    
    func showSuccessCreatingAccountNotification() {
        print("Successful account creation")
        //        TODO:
    }
    
    func showSuccessLoggingInNotification() {
        print("Successful login")
        //        TODO:
    }
}
