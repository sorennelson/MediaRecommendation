//
//  LeftTVMediaCVCell.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/19/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Cocoa

class LeftTVMediaCVCell: NSCollectionViewItem {
    
    var media: Media? {
        didSet {
            setImage()
        }
    }
    
    func setImage() {
        guard isViewLoaded else { return }
        
        guard let media = media else {
            // TODO: ImageView set to default. Set here so regardless of how long completion takes, it will be set
            return
        }
        media.getImageData(completion: { (data) in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageView?.image = NSImage(data: data)
                }
            } else {
                // TODO: ImageView set to default. Set here so regardless of how long completion takes, it will be set
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
//        view.layer?.backgroundColor = NSColor.white.cgColor
    }
    
}
