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
            // yearLabel.stringValue = year + "  |  " + medium
            
            if !media!.genres.isEmpty {
                genreLabel.stringValue = media!.genres[0]
                for i in 1 ..< media!.genres.count {
                    genreLabel.stringValue +=  ", " + media!.genres[i]
                }
            }
            
            ratingLabel.stringValue = String(format: "%.1f", userRating!) + "  |  " + String(format: "%.1f", media!.getAvgRating())
            
            media!.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.image.image = NSImage(data: data)
                    }
                } else {
                    // TODO: ImageView set to default. Set here so regardless of how long completion takes, it will be set
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
