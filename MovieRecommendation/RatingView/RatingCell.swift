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
    
    // TODO: Change to type Media
    var media: Movie! {
        didSet {
            titleLabel.stringValue = media.title
            // yearLabel.stringValue = year + "  |  " + medium
            if !media.genres.isEmpty {
                genreLabel.stringValue = media.genres[0]
                for i in 1 ..< media.genres.count {
                    genreLabel.stringValue +=  ", " + media.genres[i]
                }
            }
            
            // TODO: Static current user
            //ratingLabel.stringValue = String(format: "%.1f", myRating) + "  |  " + String(format: "%.1f", overallRating)
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        customView.layer?.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    
}
