//
//  CategoriesTableView.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/27/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class CategoriesTableView : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    let categoriesCellID = "CategoryCell"
    let categoriesTitleCellID = "TitleCell"
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch row {
        case 0 :
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: categoriesTitleCellID), owner: nil) as! TitleCell
            cell.header = "Categories"
            return cell
            
        default :
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: categoriesCellID), owner: nil) as! CategoryCell
            return cell
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == 0 { return 62 }
        return 222
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}
