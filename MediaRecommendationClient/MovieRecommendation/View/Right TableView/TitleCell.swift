//
//  TitleCell.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 12/18/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class TitleCell : NSTableCellView {

    @IBOutlet var titleHeaderLabel: NSTextField!
    @IBOutlet var arrowButton: NSButton!
    @IBOutlet var addButton: NSButton!
    
    var leadingMargin : Double? {
        didSet {
            // TODO: Connect leading margin and set constant
        }
    }
    var header: String! {
        didSet {
            titleHeaderLabel.stringValue = header
        }
    }
    
    func setHeader(_ content: Content) {
        switch content {
        case .Recommendations:
            if ObjectController.currentMediaType == .Movies  {  header = "Movie Recommendations"  }
            else  {  header = "Book Recommendations"  }
        case .Ratings:
            header = "My Ratings"
        case .Categories:
            header = "Genres"
        case .MostRecent:
            if ObjectController.currentMediaType == .Movies  {  header = "Most Recent Movies"  }
            else  {  header = "Most Recent Books"  }
        case .MostViewed:
            if ObjectController.currentMediaType == .Movies  {  header = "Most Viewed Movies"  }
            else  {  header = "Most Viewed Books"  }
        case .Series:
            if ObjectController.currentMediaType == .Movies  {  header = "Movie Series"  }
            else  {  header = "Book Series"  }
        }
    }
    
    func toggleArrowButtonDirection(_ expanding: Bool) {
        if expanding {
            arrowButton.image = NSImage(named: "icons8-expand-arrow")
        } else {
            arrowButton.image = NSImage(named: "icons8-expand-arrow-right")
        }
    }
    
    func toggleHideButtons(_ hide: Bool) {
        arrowButton.isHidden = hide
        addButton.isHidden = hide
    }

    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("Add")
    }
    
}
