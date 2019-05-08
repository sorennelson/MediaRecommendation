//
//  TitleCell.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/18/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class TitleCell : NSTableCellView {

    @IBOutlet var titleHeaderLabel: NSTextField!
    var isArrowRight = true
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
            if ObjectController.currentMediaType == .Movies {
                header = "All Movies"
            } else {
                header = "All Books"
            }
        case .Ratings:
            header = "My Ratings"
        case .Categories:
            header = "Categories"
        }
    }
    
    func toggleArrowButtonDirection() {
        if isArrowRight {
            
            arrowButton.image = NSImage(named: "icons8-expand-arrow")
        } else {
            arrowButton.image = NSImage(named: "icons8-expand-arrow-right")
        }
        isArrowRight = !isArrowRight
    }
    
    func toggleHideButtons() {
        arrowButton.isHidden = !arrowButton.isHidden
        addButton.isHidden = !addButton.isHidden
    }

    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("A")
        
    }
    
}
