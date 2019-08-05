//
//  RightTVMediaCell.swift
//  MediaRecommendation
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
            
            ratingLabel.stringValue = "Rating: " + String(format: "%.1f", userRating!) + "  |  Avg: " + String(format: "%.1f", media!.avgRating / 2)
            
            media!.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async  {  self.image.image = NSImage(data: data)  }
                } else {
                    self.image.image = NSImage(named: "no-image")
                }
            })
        }
    }
    
    override func viewWillDraw() {
        customView.layer?.backgroundColor = CGColor(red: 0.15, green: 0.16, blue: 0.17, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
