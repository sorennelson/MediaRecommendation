//
//  RatingTitleCell.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/18/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class TitleCell : NSTableCellView {

    @IBOutlet var titleHeaderLabel: NSTextField!
    
    var leadingMargin : Double? {
        didSet {
            //            TODO: Connect leading margin and set constant
        }
    }
    var header: String! {
        didSet {
            titleHeaderLabel.stringValue = header
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
