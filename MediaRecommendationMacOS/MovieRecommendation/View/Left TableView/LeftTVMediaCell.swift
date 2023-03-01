//
//  LeftTVMediaCell.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 5/3/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class LeftTVMediaCell: NSTableCellView {
    
    @IBOutlet var leftImageButton: NSButton!
    @IBOutlet var leftLabel: NSTextField!
    
    @IBOutlet var middleImageButton: NSButton!
    @IBOutlet var middleLabel: NSTextField!
    
    @IBOutlet var rightImageButton: NSButton!
    @IBOutlet var rightLabel: NSTextField!
    
    var reloadDelegate: ReloadContent?
    
    var leftMedia: Media? {
        didSet {
            guard let media = leftMedia else { return }
            leftLabel.stringValue = media.title
                media.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async  {  self.leftImageButton.image = NSImage(data: data)  }
                } else {
                    DispatchQueue.main.async  {  self.leftImageButton.image = NSImage(named: "no-image")  }
                }
            })
        }
    }
    
    var middleMedia: Media? {
        didSet {
            guard let media = middleMedia else { return }
            middleLabel.stringValue = media.title
            media.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async  {  self.middleImageButton.image = NSImage(data: data)  }
                } else {
                    DispatchQueue.main.async  {  self.middleImageButton.image = NSImage(named: "no-image")  }
                }
            })
        }
    }
    
    var rightMedia: Media? {
        didSet {
            guard let media = rightMedia else { return }
            rightLabel.stringValue = media.title
            media.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async  {  self.rightImageButton.image = NSImage(data: data)  }
                } else {
                    DispatchQueue.main.async  {  self.rightImageButton.image = NSImage(named: "no-image")  }
                }
            })
        }
    }
    
    func setMedia(media: [Media]) {
        if media.count > 0 { leftMedia = media[0] }
        if media.count > 1 { middleMedia = media[1] }
        if media.count > 2 { rightMedia = media[2] }
    }
    
    //    MARK: Book Series
    var leftBookSeries: BookSeries? {
        didSet {
            leftLabel.stringValue = leftBookSeries!.name
            leftBookSeries!.showMedia.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async  {  self.leftImageButton.image = NSImage(data: data)  }
                } else {
                    DispatchQueue.main.async  {  self.leftImageButton.image = NSImage(named: "no-image")  }
                }
            })
        }
    }
    
    var middleBookSeries: BookSeries? {
        didSet {
            middleLabel.stringValue = middleBookSeries!.name
            middleBookSeries!.showMedia.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async  {  self.middleImageButton.image = NSImage(data: data)  }
                } else {
                    DispatchQueue.main.async  {  self.middleImageButton.image = NSImage(named: "no-image")  }
                }
            })
        }
    }
    
    var rightBookSeries: BookSeries? {
        didSet {
            rightLabel.stringValue = rightBookSeries!.name
            rightBookSeries!.showMedia.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async  {  self.rightImageButton.image = NSImage(data: data)  }
                } else {
                    DispatchQueue.main.async  {  self.rightImageButton.image = NSImage(named: "no-image")  }
                }
            })
        }
    }
    
    func setBookSeries(series: [BookSeries]) {
        if series.count > 0 { leftBookSeries = series[0] }
        if series.count > 1 { middleBookSeries = series[1] }
        if series.count > 2 { rightBookSeries = series[2] }
        leftMedia = nil
        middleMedia = nil
        rightMedia = nil
    }
    
    //    MARK: Movie Series
    var leftMovieSeries: MovieSeries? {
        didSet {
            leftLabel.stringValue = leftMovieSeries!.name
            leftMovieSeries!.showMedia.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async  {  self.leftImageButton.image = NSImage(data: data)  }
                } else {
                    DispatchQueue.main.async  {  self.leftImageButton.image = NSImage(named: "no-image")  }
                }
            })
        }
    }
    
    var middleMovieSeries: MovieSeries? {
        didSet {
            middleLabel.stringValue = middleMovieSeries!.name
            middleMovieSeries!.showMedia.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async  {  self.middleImageButton.image = NSImage(data: data)  }
                } else {
                    DispatchQueue.main.async  {  self.middleImageButton.image = NSImage(named: "no-image")  }
                }
            })
        }
    }
    
    var rightMovieSeries: MovieSeries? {
        didSet {
            rightLabel.stringValue = rightMovieSeries!.name
            rightMovieSeries!.showMedia.getImageData(completion: { (data) in
                if let data = data {
                    DispatchQueue.main.async  {  self.rightImageButton.image = NSImage(data: data)  }
                } else {
                    DispatchQueue.main.async  {  self.rightImageButton.image = NSImage(named: "no-image")  }
                }
            })
        }
    }
    
    func setMovieSeries(series: [MovieSeries]) {
        if series.count > 0 { leftMovieSeries = series[0] }
        if series.count > 1 { middleMovieSeries = series[1] }
        if series.count > 2 { rightMovieSeries = series[2] }
        leftMedia = nil
        middleMedia = nil
        rightMedia = nil
    }
    
    //    MARK: Selection
    @IBAction func leftButtonClicked(_ sender: Any) {
        if let media = leftMedia {
            self.setSelectedMedia(media)
            
        } else if ObjectController.currentMediaType == .Movies {
            guard let series = leftMovieSeries else { return }
            // TODO: New view to show the entire series
            self.setSelectedMedia(series.showMedia)
            
        } else if ObjectController.currentMediaType == .Books {
            guard let series = leftBookSeries else { return }
            self.setSelectedMedia(series.showMedia)
        }
    }
    
    @IBAction func middleButtonClicked(_ sender: Any) {
        if let media = middleMedia {
            self.setSelectedMedia(media)
            
        } else if ObjectController.currentMediaType == .Movies {
            guard let series = middleMovieSeries else { return }
            // TODO: New view to show the entire series
            self.setSelectedMedia(series.showMedia)
            
        } else if ObjectController.currentMediaType == .Books {
            guard let series = middleBookSeries else { return }
            self.setSelectedMedia(series.showMedia)
        }
    }
    
    @IBAction func rightButtonClicked(_ sender: Any) {
        if let media = rightMedia {
            self.setSelectedMedia(media)
            
        } else if ObjectController.currentMediaType == .Movies {
            guard let series = rightMovieSeries else { return }
            // TODO: New view to show the entire series
            self.setSelectedMedia(series.showMedia)
            
        } else if ObjectController.currentMediaType == .Books {
            guard let series = rightBookSeries else { return }
            self.setSelectedMedia(series.showMedia)
        }
    }
    
    func setSelectedMedia(_ media: Media) {
        ObjectController.sharedInstance.selectedMedia = media
//        self.displayPopover()
        ImportController.sharedInstance.loadRecommendation(media: media) { success, error, pred in
            if success, let pred = pred {
                ObjectController.sharedInstance.selectedMediaPrediction = Double(pred)
            }
            self.displayPopover()
        }
    }
    
    func displayPopover() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let popover = NSPopover()
        let mediaDetail = storyboard.instantiateController(withIdentifier: "MediaDetailPopover") as! MediaDetailPopover
        popover.behavior = .transient
        popover.contentViewController = mediaDetail
        popover.show(relativeTo: superview!.bounds, of: superview!, preferredEdge: .maxX)
        mediaDetail.reloadDelegate = reloadDelegate
    }
    
}

