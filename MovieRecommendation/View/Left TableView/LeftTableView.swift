//
//  LeftTableView.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/18/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class LeftTableView : NSObject, NSTableViewDelegate, NSTableViewDataSource  {
    
// MARK: TableView
    var tableView: NSTableView?
    let CollectionCellID = "CVCell"
    let MediaCellID = "MediaCellID"
    let TitleCellID = "TitleCell"
    var titleCell: TitleCell?
    
    func setTableView(_ tableView: NSTableView) {
        self.tableView = tableView
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        self.tableView!.backgroundColor = NSColor(red: 0.0898, green: 0.0938, blue: 0.0938, alpha: 1)
        self.tableView!.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let count = ObjectController.sharedInstance.getAllMediaCount()
        if count == 0 { return 1 }
        else { return 1 + ceil(Double(count) / 3.0) }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch row {
        case 0 :
            titleCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: TitleCellID), owner: nil) as? TitleCell
            titleCell!.setHeader(currentContent)
            return titleCell
            
        default :
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: MediaCellID), owner: nil) as! LeftTVMediaCell
            let media = ObjectController.sharedInstance.getAllMedia(for: (row-1)*3..<(row-1)*3+3)
            cell.setMedia(media: media)
            return cell
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == 0 { return 90 }
        return 320
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    
    // MARK: Content
    
    var currentContent = Content.Recommendations
    
    func changeContent(to content: Content) {
        currentContent = content
        tableView?.reloadData()
    }
    
    func toggleArrowButtonDirection() {
        titleCell!.toggleArrowButtonDirection()
    }
    
}
