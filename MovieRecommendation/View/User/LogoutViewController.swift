//
//  LogoutViewController.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 5/4/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class LogoutViewController: NSViewController {
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
         UserController.sharedInstance.logout()
    }
    
}
