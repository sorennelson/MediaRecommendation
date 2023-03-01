//
//  RightTVCategoryCell.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 5/7/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class RightTVCategoryCell: NSTableCellView {
    
    var selected = false
    @IBOutlet var selectedView: NSView!
    @IBOutlet var countLabel: NSTextField!
    @IBOutlet var categoryTitle: NSTextField!
    
    var category: Genre? {
        didSet {
            self.categoryTitle.stringValue = category!.name
            self.countLabel.stringValue = String(category!.count)
        }
    }
    
    override func viewWillDraw() {
        if selected {
            selectedView.layer?.backgroundColor = .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        } else {
            selectedView.layer?.backgroundColor = .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.0)
        }
    }
    
    func select() {
        selectedView.layer?.backgroundColor = .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        selected = true
    }
    
    func deselect() {
        selectedView.layer?.backgroundColor = .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.0)
        selected = false
    }
}
