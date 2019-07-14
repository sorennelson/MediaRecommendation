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
                    DispatchQueue.main.async {
                        self.leftImageButton.image = NSImage(named: "no-image")
                    }
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
                    DispatchQueue.main.async {
                        self.middleImageButton.image = NSImage(named: "no-image")
                    }
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
                    DispatchQueue.main.async {
                        self.rightImageButton.image = NSImage(named: "no-image")
                    }
                }
            })
        }
    }
    
    func setMedia(media: [Media]) {
        leftMedia = media[0]
        if media.count > 1 { middleMedia = media[1] }
        if media.count > 2 { rightMedia = media[2] }
    }
    
    @IBAction func leftButtonClicked(_ sender: Any) {
        guard let media = leftMedia else { return }
        let prediction = ObjectController.sharedInstance.getPrediction(for: media)
        setSelectedMedia(media, prediction: prediction)
        displayPopover()
    }
    
    @IBAction func middleButtonClicked(_ sender: Any) {
        guard let media = middleMedia else { return }
        let prediction = ObjectController.sharedInstance.getPrediction(for: media)
        setSelectedMedia(media, prediction: prediction)
        displayPopover()
    }
    
    @IBAction func rightButtonClicked(_ sender: Any) {
        guard let media = rightMedia else { return }
        let prediction = ObjectController.sharedInstance.getPrediction(for: media)
        setSelectedMedia(media, prediction: prediction)
        displayPopover()
    }
    
    func setSelectedMedia(_ media: Media, prediction: Double) {
        ObjectController.sharedInstance.selectedMedia = media
        ObjectController.sharedInstance.selectedMediaPrediction = prediction
    }
    
    func displayPopover() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let popover = NSPopover()
        let mediaDetail = storyboard.instantiateController(withIdentifier: "MediaDetailPopover") as! MediaDetailPopover
        popover.behavior = .transient
        popover.contentViewController = mediaDetail
        popover.show(relativeTo: superview!.bounds, of: superview!, preferredEdge: .maxX)
        
    }
    
}

