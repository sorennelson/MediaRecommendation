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
    @IBOutlet var countLabel: NSTextField!
    @IBOutlet var categoryTitle: NSTextField!
    var category = "All"
    
    func select() {
        selectedView.layer?.backgroundColor = .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    }
    
    func deselect() {
        selectedView.layer?.backgroundColor = .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.0)
    }
}
