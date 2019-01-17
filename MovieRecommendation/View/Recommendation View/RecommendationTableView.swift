//
//  RecommendationTableView.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/18/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class RecommendationTableView : NSObject, NSTableViewDelegate, NSTableViewDataSource  {
    
    let collectionCellID = "CVCell"
    let headerCellID = "TitleCell"
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch row {
        case 0 :
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: headerCellID), owner: nil) as! TitleCell
            cell.header = "Top Recommendations"
            return cell
            
        default :
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: collectionCellID), owner: nil) as! RecommendationTableViewCell
            //            cell.media =
            return cell
            
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == 0 { return 62 }
        return 515
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
}
