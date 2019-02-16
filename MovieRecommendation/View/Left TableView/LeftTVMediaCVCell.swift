//
//  LeftTVMediaCVCell.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/19/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Cocoa

class LeftTVMediaCVCell: NSCollectionViewItem {
    
    var image: NSImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView?.image = image ?? nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
    }
    
}
