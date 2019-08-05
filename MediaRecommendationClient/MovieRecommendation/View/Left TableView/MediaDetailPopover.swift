//
//  MediaDetailPopover.swift
//  MediaRecommendation
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
    
    override func viewDidLoad() {
        guard let media = ObjectController.sharedInstance.selectedMedia,
            let prediction = ObjectController.sharedInstance.selectedMediaPrediction else {
                predictionMessageLabel.stringValue = "The model is not done being trained"
                return
        }
        media.getImageData(completion: { (data) in
            if let data = data {
                DispatchQueue.main.async { self.image.image = NSImage(data: data) }
            }
        })
        
        let mediaType = ObjectController.currentMediaType
        if mediaType == .Books {
                let pred = Double(prediction * 100 / 100.0)
                self.prediction.stringValue = String(pred)
                self.predictionMessageLabel.stringValue = ""
//            if let rating = ObjectController.sharedInstance.currentUser?.booksRated[media.yID] {
//                self.userRating.stringValue = String(rating)
//            } else {
                self.userRating.stringValue = "Not Yet Rated"
//            }
            
        } else {
                let pred = Double(prediction * 100 / 100.0)
                self.prediction.stringValue = String(pred)
                self.predictionMessageLabel.stringValue = ""
//            if let rating = ObjectController.sharedInstance.currentUser?.moviesRated[media.yID] {
//                self.userRating.stringValue = String(rating)
//            } else {
                self.userRating.stringValue = "Not Yet Rated"
//            }
        }
        let avg = Double(media.avgRating * 100 / 100.0)
        self.avgRating.stringValue = String(avg)
        self.titleLabel.stringValue = media.title
    }
    
}
