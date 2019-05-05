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
        
        ObjectController.sharedInstance.createUser(email: emailTextField.stringValue, password: passwordTextField.stringValue) { (success) in
            if !success {
                self.showErrorCreatingAccountNotification()
                
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
        
        ObjectController.sharedInstance.signIn(email: emailTextField.stringValue, password: passwordTextField.stringValue) { (success) in
            if !success {
                self.showErrorLoggingInNotification()
                
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
//            TODO: force better password
            return true
        }
        return false
    }
    
    func showInvalidEmailPasswordNotification() {
        print("Bad Email / Password")
//            TODO:
    }
    
    func showErrorCreatingAccountNotification() {
        print("Error creating Account")
        //        TODO:
    }
    
    func showErrorLoggingInNotification() {
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
