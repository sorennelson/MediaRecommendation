//
//  RatingsTableView.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 11/27/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class RatingsTableView: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    let ratingCellID = "MovieRatingCell"
    let ratingTitleCellID = "TitleCell"
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch row {
        case 0 :
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: ratingTitleCellID), owner: nil) as! TitleCell
            cell.header = "My Ratings"
            return cell
            
        default :
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: ratingCellID), owner: nil) as! RatingCell
            //            cell.media =
            return cell
        
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == 0 { return 62 }
        return 153
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if (row == 0) { return false }
        return true
    }
    
}
