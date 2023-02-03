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
//    @IBOutlet var userRating: NSTextField!
    @IBOutlet var avgRating: NSTextField!
    @IBOutlet var prediction: NSTextField!
    @IBOutlet weak var yearType: NSTextField!
    @IBOutlet weak var genres: NSTextField!
    
    @IBOutlet var saveButton: NSButton!
    @IBOutlet var button5: NSButton!
    @IBOutlet var button4: NSButton!
    @IBOutlet var button3: NSButton!
    @IBOutlet var button2: NSButton!
    @IBOutlet var button1: NSButton!
    
    var rating = 0
    var reloadDelegate: ReloadContent?
    
    
    override func viewDidLoad() {
        guard let media = ObjectController.sharedInstance.selectedMedia else { return }
        media.getImageData(completion: { (data) in
            if let data = data {
                DispatchQueue.main.async { self.image.image = NSImage(data: data) }
            }
        })
        self.avgRating.stringValue = String(format: "%.2f", media.avgRating)
        self.titleLabel.stringValue = media.title
        
        let mediaType = ObjectController.currentMediaType
        if mediaType == .Books {
//            if let rating = ObjectController.sharedInstance.currentUser?.booksRated[media.yID] {
//                self.userRating.stringValue = String(rating)
//            } else {
//            self.userRating.stringValue = "Not Yet Rated"
            yearType.stringValue = String(media.year) + " | Book"
            
        } else {
//            if let rating = ObjectController.sharedInstance.currentUser?.moviesRated[media.yID] {
//                self.userRating.stringValue = String(rating)
//            } else {
//            self.userRating.stringValue = "Not Yet Rated"
            yearType.stringValue = String(media.year) + " | Movie"
        }
        
        // Set Genres
        var genresStr = ""
        for i in 0..<media.genres.count-1 {
            genresStr += media.genres[i] + ", "
        }
        genresStr += media.genres[media.genres.count-1]
        genres.stringValue = genresStr
        
        guard let prediction = ObjectController.sharedInstance.selectedMediaPrediction else { return }
        self.prediction.stringValue = String(format: "%.2f", prediction)
        
    }
    
    
    @IBAction func button5Pressed(_ sender: Any) {
        resetStates(except: 5)
        rating = 5
    }
    
    @IBAction func button4Pressed(_ sender: Any) {
        resetStates(except: 4)
        rating = 4
    }
    
    @IBAction func button3Pressed(_ sender: Any) {
        resetStates(except: 3)
        rating = 3
    }
    
    @IBAction func button2Pressed(_ sender: Any) {
        resetStates(except: 2)
        rating = 2
    }
    
    @IBAction func button1Pressed(_ sender: Any) {
        resetStates(except: 1)
        rating = 1
    }
    
    private func resetStates(except exception: Int) {
        if exception != 5 {
            button5.state = .off
        }
        if exception != 4 {
            button4.state = .off
        }
        if exception != 3 {
            button3.state = .off
        }
        if exception != 2 {
            button2.state = .off
        }
        if exception != 1 {
            button1.state = .off
        }
    }
    
    func setRating(rating: Int) {
        self.rating = rating
        if rating == 5 {
            button5.state = .on
        } else if rating == 4 {
            button4.state = .on
        } else if rating == 3 {
            button3.state = .on
        } else if rating == 2 {
            button2.state = .on
        } else if rating == 1 {
            button1.state = .on
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        resetStates(except: 0)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let media = ObjectController.sharedInstance.selectedMedia else { return }
        ObjectController.sharedInstance.addRating(Float(rating), for: media, completion: { (success, err) in
            ImportController.sharedInstance.removeRatingsFromAllMedia(of: ObjectController.currentMediaType)
            // Reload table views
            self.reloadDelegate?.reload()
        })
        self.view.window?.performClose(sender)
    }
    
}
