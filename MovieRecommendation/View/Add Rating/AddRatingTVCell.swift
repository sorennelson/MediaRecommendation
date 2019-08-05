//
//  AddRatingTVCell.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 4/20/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class AddRatingTVCell: NSTableCellView {
    
    @IBOutlet var mediaImage: NSImageView!
    @IBOutlet var title: NSTextField!
    @IBOutlet var yearAndType: NSTextField!
    @IBOutlet var genres: NSTextField!
    @IBOutlet var average: NSTextField!
    
    var media: Media? {
        didSet {
            title.stringValue = media!.title
            setGenre()
            setYearAndType()
            setAvg()
            setImage()
        }
    }
    
    private func setGenre() {
        genres.stringValue = ""
        for i in 0..<media!.genres.count-1 {
            genres.stringValue += media!.genres[i] + ", "
        }
        genres.stringValue += media!.genres[media!.genres.count-1]
    }
    
    private func setYearAndType() {
        if media! is Movie {
            yearAndType.stringValue = String(media!.year) + " | Movie"
        } else if media! is Book {
            yearAndType.stringValue = String(media!.year) + " | Book"
        }
    }
    
    private func setAvg() {
        if let rating = ObjectController.sharedInstance.getRating(for: media!) {
            average.stringValue = "Rating: " +  String(rating)
        } else {
            average.stringValue = "Avg: " + String(Double(Int(media!.avgRating * 100.0)) / 200.0)
        }
    }
    
    private func setImage() {
        media!.getImageData(completion: { (data) in
            if let data = data {
                DispatchQueue.main.async {
                    self.mediaImage.image = NSImage(data: data)
                }
            }
        })
    }
    
}
