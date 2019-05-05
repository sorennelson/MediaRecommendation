//
//  MediaDetailPopover.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 5/4/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class MediaDetailPopover: NSViewController {
    
    @IBOutlet var titleLabel: NSTextField!
    
    @IBOutlet var image: NSImageView!
    @IBOutlet var userRating: NSTextField!
    @IBOutlet var avgRating: NSTextField!
    @IBOutlet var prediction: NSTextField!
    @IBOutlet var predictionMessageLabel: NSTextField!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        guard let media = ObjectController.sharedInstance.selectedMedia,
            let prediction = ObjectController.sharedInstance.selectedMediaPrediction else {
                return
        }
        media.getImageData(completion: { (data) in
            if let data = data {
                DispatchQueue.main.async {
                    self.image.image = NSImage(data: data)
                }
            }
        })
        self.titleLabel.stringValue = media.title
        let mediaType = ObjectController.currentMediaType
        if mediaType == .Books {
            if let rating = ObjectController.sharedInstance.currentUser?.booksRated[media.yID] {
                self.userRating.stringValue = String(rating)
            } else {
                self.userRating.stringValue = "Not Yet Rated"
            }
            
        } else {
            if let rating = ObjectController.sharedInstance.currentUser?.moviesRated[media.yID] {
                self.userRating.stringValue = String(rating)
            } else {
                self.userRating.stringValue = "Not Yet Rated"
            }
        }
        self.avgRating.stringValue = String(media.getAvgRating())
        self.prediction.stringValue = String(prediction)
        
    }
    
}
