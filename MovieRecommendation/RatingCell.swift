//
//  RatingCell.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/18/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class RatingCell : NSTableCellView {
    
    
    @IBOutlet var customView: NSView!
    @IBOutlet var image: NSImageView!

    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var yearLabel: NSTextField!
    @IBOutlet var genreLabel: NSTextField!
    @IBOutlet var ratingLabel: NSTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        customView.layer?.backgroundColor = CGColor(red: 52, green: 53, blue: 56, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setValues(image: NSImage?, title: String, genres: String, year: String, medium: String, myRating: Double, overallRating: Double) {
        titleLabel.stringValue = title
        yearLabel.stringValue = year + "  |  " + medium
        genreLabel.stringValue = genres
        ratingLabel.stringValue = String(format: "%.1f", myRating) + "  |  " + String(format: "%.1f", overallRating)
    }

    
}
