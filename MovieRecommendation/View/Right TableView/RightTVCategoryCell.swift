//
//  RightTVCategoryCell.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 5/7/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class RightTVCategoryCell: NSTableCellView {
    
    @IBOutlet var selectedView: NSView!
    @IBOutlet var ratingLabel: NSTextField!
    @IBOutlet var categoryTitle: NSTextField!
    var category = "All"
    
    func select() {
        selectedView.isHidden = true
    }
    
    func deselect() {
        selectedView.isHidden = false
    }
}
