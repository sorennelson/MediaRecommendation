//
//  RightTVMediaCell.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/18/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class RightTVMediaCell : NSTableCellView {
    
    @IBOutlet var customView: NSView!
    @IBOutlet var image: NSImageView!

    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var yearLabel: NSTextField!
    @IBOutlet var genreLabel: NSTextField!
    @IBOutlet var ratingLabel: NSTextField!
    
    var userRating: Double?
    var media: Media? {
        didSet {
            titleLabel.stringValue = media!.title
            
            let medium = ObjectController.currentMediaType == .Books ? "Book" : "Movie"
            yearLabel.stringValue = String(media!.year) + "  |  " + medium
            
            genreLabel.stringValue = media!.genres[0]
            for i in 1 ..< media!.genres.count {
                genreLabel.stringValue +=  ", " + media!.genres[i]
            }
            
            ratingLabel.stringValue = String(format: "%.1f", userRating!) + "  |  " + String(format: "%.1f", media!.avgRating)
            
            media!.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async  {  self.image.image = NSImage(data: data)  }
                } else {
                    self.image.image = NSImage(named: "no-image")
                }
            })
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
