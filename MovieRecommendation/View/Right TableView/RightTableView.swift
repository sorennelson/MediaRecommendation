//
//  RightTableView.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 11/27/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class RightTableView: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
// MARK: TableView
    
    var tableView: NSTableView?
    let MediaCellID = "MovieRatingCell"
    let TitleCellID = "TitleCell"
    var titleCell: TitleCell?
    var ratings = [Media]()
    
    func setTableView(_ tableView: NSTableView) {
        self.tableView = tableView
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        self.tableView!.backgroundColor = NSColor(red: 0.1205, green: 0.1232, blue: 0.1287, alpha: 1)
        self.tableView!.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        ratings = Array(ObjectController.sharedInstance.getRatings().keys)
//        title + ratings
        return ratings.count + 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch row {
        case 0 :
            titleCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: TitleCellID), owner: nil) as? TitleCell
            titleCell!.setHeader(currentContent)
            return titleCell
            
        default :
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: MediaCellID), owner: nil) as! RightTVMediaCell
            let media = ratings[row - 1]
            cell.userRating = ObjectController.sharedInstance.getRatings()[media]!
            cell.media = media
            return cell
        
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == 0 { return 90 }
        return 153
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if (row == 0) { return false }
        return true
    }
    
// MARK: Content
    
    var currentContent = Content.Ratings
    
    func changeContent(to content: Content) {
        currentContent = content
        titleCell!.toggleHideButtons()
        tableView?.reloadData()
    }
    
}
