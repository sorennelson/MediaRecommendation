//
//  CategoryCell.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 12/27/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Cocoa

class CategoryCell : NSTableCellView {
    
    @IBOutlet var firstImage: NSButton!
    @IBOutlet var secondImage: NSButton!
    @IBOutlet var thirdImage: NSButton!
    var contentDelegate: UpdateContent?
    
    @IBAction func mostWatchedButtonPressed(_ sender: Any) {
        //        TODO: Update button image
        ObjectController.sharedInstance.setMostViewed()
        contentDelegate?.changeContent(to: .MostViewed)
    }
    
    @IBAction func mostRecentButtonPressed(_ sender: Any) {
        //        TODO: Update button image
        ObjectController.sharedInstance.setMostRecent()
        contentDelegate?.changeContent(to: .MostRecent)
    }
    
    @IBAction func seriesButtonPressed(_ sender: Any) {
        //        TODO: Update button image
        ImportController.sharedInstance.loadSeries { (success, str) in
            if !success {
                //  TODO: ERROR NOTIFICATION
                print(str)
            } else {
                self.contentDelegate?.changeContent(to: .Series)
            }
        }
    }
    
    
}
