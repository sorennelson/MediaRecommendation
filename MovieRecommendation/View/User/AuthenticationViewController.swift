//
//  CreateUserViewController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 5/2/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class AuthenticationViewController: NSViewController {
    
    @IBOutlet var emailTextField: NSTextField!
    @IBOutlet var passwordTextField: NSSecureTextField!
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        if !isValidEmailPassword() {
            self.showInvalidEmailPasswordNotification()
            return
        }
        
        UserController.sharedInstance.createUser(email: emailTextField.stringValue, password: passwordTextField.stringValue) { (success, error)in
            if !success {
                self.showErrorCreatingAccountNotification(error!)
                
            } else {
                self.showSuccessCreatingAccountNotification()
                self.presentingViewController?.dismiss(self)
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if !isValidEmailPassword() {
            self.showInvalidEmailPasswordNotification()
            return
        }
        
        UserController.sharedInstance.signIn(email: emailTextField.stringValue, password: passwordTextField.stringValue) { (success, error) in
            if !success {
                self.showErrorLoggingInNotification(error!)
                
            } else {
                self.showSuccessLoggingInNotification()
                self.presentingViewController?.dismiss(self)
            }
        }
    }
    
    func isValidEmailPassword() -> Bool {
        if emailTextField.stringValue.contains("@")
            && emailTextField.stringValue.contains(".")
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
