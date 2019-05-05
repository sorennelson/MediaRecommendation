//
//  LeftTVMediaCell.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 5/3/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class LeftTVMediaCell: NSTableCellView {
    
    @IBOutlet var leftImageButton: NSButton!
    @IBOutlet var middleImageButton: NSButton!
    @IBOutlet var rightImageButton: NSButton!
    
    var leftMedia: Media? {
        didSet {
            leftMedia!.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.leftImageButton.image = NSImage(data: data)
                    }
                } else {
                    // TODO: ImageView set to default. Set here so regardless of how long completion takes, it will be set
                }
            })
        }
    }
    
    var middleMedia: Media? {
        didSet {
            middleMedia!.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.middleImageButton.image = NSImage(data: data)
                    }
                } else {
                    // TODO: ImageView set to default. Set here so regardless of how long completion takes, it will be set
                }
            })
        }
    }
    
    var rightMedia: Media? {
        didSet {
            rightMedia!.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.rightImageButton.image = NSImage(data: data)
                    }
                } else {
                    // TODO: ImageView set to default. Set here so regardless of how long completion takes, it will be set
                }
            })
        }
    }
    
    func setMedia(media: [Media]) {
        leftMedia = media[0]
        if media.count > 1 {
            middleMedia = media[1]
        }
        if media.count > 2 {
            rightMedia = media[2]
        }
    }
    
    @IBAction func leftButtonClicked(_ sender: Any) {
        guard let media = leftMedia else { return }
        let user = ObjectController.sharedInstance.movieUsers[0]
        let prediction = ObjectController.sharedInstance.getPrediction(for: user, media: media)
        print(prediction)
        setSelectedMedia(media, prediction: prediction)
    }
    
    @IBAction func middleButtonClicked(_ sender: Any) {
        guard let media = middleMedia else { return }
        let user = ObjectController.sharedInstance.movieUsers[0]
        let prediction = ObjectController.sharedInstance.getPrediction(for: user, media: media)
        print(prediction)
        setSelectedMedia(media, prediction: prediction)
    }
    
    @IBAction func rightButtonClicked(_ sender: Any) {
        guard let media = rightMedia else { return }
        let user = ObjectController.sharedInstance.movieUsers[0]
        let prediction = ObjectController.sharedInstance.getPrediction(for: user, media: media)
        print(prediction)
        setSelectedMedia(media, prediction: prediction)
    }
    
    func setSelectedMedia(_ media: Media, prediction: Double) {
        ObjectController.sharedInstance.selectedMedia = media
        ObjectController.sharedInstance.selectedMediaPrediction = prediction
    }
}

