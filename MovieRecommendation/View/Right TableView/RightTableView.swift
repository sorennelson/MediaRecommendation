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
    let CategoryCellID = "CategoryCell"
    let TitleCellID = "TitleCell"
    var titleCell: TitleCell?
    
    var ratings = [Media]()
    var selectedCategoryRow = -1
    var selectedCategory = ""
    
    
    func setTableView(_ tableView: NSTableView) {
        self.tableView = tableView
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        self.tableView!.backgroundColor = NSColor(red: 0.1205, green: 0.1232, blue: 0.1287, alpha: 1)
        self.tableView!.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if currentContent == .Ratings {
            ratings = Array(ObjectController.sharedInstance.getRatings().keys)
            // Title + ratings
            return ratings.count + 1
        } else {
            // Title + "all categories" + categories
            return ObjectController.sharedInstance.getAllCategories().count + 2
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch row {
        case 0 :
            titleCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: TitleCellID), owner: nil) as? TitleCell
            titleCell!.setHeader(currentContent)
            return titleCell
            
        default :
            if currentContent == .Ratings {
                return getRatingCellView(tableView: tableView, row: row)
            } else {
                return getCategoryCellView(tableView: tableView, row: row)
            }
        }
    }
    
    private func getRatingCellView(tableView: NSTableView, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: MediaCellID), owner: nil) as! RightTVMediaCell
        let media = ratings[row - 1]
        cell.userRating = ObjectController.sharedInstance.getRatings()[media]!
        cell.media = media
        return cell
    }
    
    private func getCategoryCellView(tableView: NSTableView, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: MediaCellID), owner: nil) as! RightTVCategoryCell
        if row > 1 {
            cell.category = ObjectController.sharedInstance.getAllCategories()[row-2]
        }
        cell.categoryTitle.stringValue = cell.category
        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == 0 { return 90 }
        return 153
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if (row == 0) { return false }
        if currentContent == .Ratings { return true }
        else {
            let oldCell = tableView.view(atColumn: 0, row: selectedCategoryRow, makeIfNecessary: false) as! RightTVCategoryCell
            oldCell.deselect()
            
            let newCell = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! RightTVCategoryCell
            newCell.select()
            
            selectedCategoryRow = row
            selectedCategory = newCell.category
// Update the left tv content to be the genre
            
            return false
        }
    }
    
// MARK: Content
    
    var currentContent = Content.Ratings
    
    func changeContent(to content: Content) {
        currentContent = content
        titleCell!.toggleHideButtons()
        tableView?.reloadData()
    }
    
}
