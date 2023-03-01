//
//  RightTableView.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 11/27/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class RightTableView: NSObject, NSTableViewDelegate, NSTableViewDataSource, ReloadContent {
    
// MARK: TableView
    var tableView: NSTableView?
    var contentDelegate: UpdateContent?
    let MediaCellID = "MovieRatingCell"
    let CategoryCellID = "CategoryCell"
    let TitleCellID = "TitleCell"
    var titleCell: TitleCell?
    
    var selectedCategoryRow = 1
    var selectedCategory = Genre(name: "All", count: 0)
    
    //    MARK: Tableview
    func setTableView(_ tableView: NSTableView) {
        self.tableView = tableView
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        self.tableView!.backgroundColor = NSColor(red: 0.13, green: 0.13, blue: 0.14, alpha: 1)
        self.tableView!.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if currentContent == .Ratings {
            // Title + ratings
            return 1 + UserController.sharedInstance.getRatingsCount()
            
        } else {
            // Title + "all categories" + categories
            return 1 + ObjectController.sharedInstance.getGenreCount() 
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == 0 { return 110 }
        else if currentContent == .Categories { return 82 }
        return 153
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if row == 0 || currentContent == .Ratings  {
            guard let (media, rating) = UserController.sharedInstance.getMediaAndRating(for: row - 1) else { return false }
            setSelectedMedia(media, with: rating)
            return false
        }
        else {
            for row in 0..<tableView.numberOfRows {
                if let oldCell = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? RightTVCategoryCell {
                    oldCell.deselect()
                }
            }
            
            let newCell = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! RightTVCategoryCell
            newCell.select()
            
            selectedCategoryRow = row
            selectedCategory = newCell.category!
            contentDelegate?.selectedCategory(selectedCategoryRow, category: selectedCategory)
            
            return false
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch row {
        case 0 :
            titleCell = getTitleCellView(tableView: tableView)
            return titleCell
            
        default :
            if currentContent == .Ratings {
                return getRatingCellView(tableView: tableView, row: row)
            } else {
                return getCategoryCellView(tableView: tableView, row: row)
            }
        }
    }
    
    //    MARK: Title Cell
    private func getTitleCellView(tableView: NSTableView) -> TitleCell? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: TitleCellID), owner: nil) as? TitleCell
        cell!.setHeader(currentContent)
        cell!.toggleHideButtons(currentContent == .Categories)
        return cell
    }
    
    //    MARK: Rating Cell
    private func getRatingCellView(tableView: NSTableView, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: MediaCellID), owner: nil) as! RightTVMediaCell
        guard let (media, rating) = UserController.sharedInstance.getMediaAndRating(for: row - 1) else { return nil }
        cell.userRating = rating
        cell.media = media
        return cell
    }
    
    //    MARK: Category Cell
    private func getCategoryCellView(tableView: NSTableView, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CategoryCellID), owner: nil) as! RightTVCategoryCell
        cell.category = ObjectController.sharedInstance.getGenre(at: row - 1)
        if row == selectedCategoryRow  {
            cell.selected = true
        } else {
            cell.selected = false
        }
        return cell
    }
    
    
    func setSelectedMedia(_ media: Media, with rating: Double) {
        ObjectController.sharedInstance.selectedMedia = media
        // TODO: Remove label
//        ObjectController.sharedInstance.selectedMediaPrediction = rating
        self.displayPopover(rating: rating)
    }
    
    func displayPopover(rating: Double) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let popover = NSPopover()
        let mediaDetail = storyboard.instantiateController(withIdentifier: "MediaDetailPopover") as! MediaDetailPopover
        popover.behavior = .transient
        popover.contentViewController = mediaDetail
        popover.show(relativeTo: self.tableView!.bounds, of: self.tableView!, preferredEdge: .maxX)
        // TODO: Handle removing of rating
        mediaDetail.reloadDelegate = self
        mediaDetail.setRating(rating: Int(rating))
    }
    
// MARK: Content
    
    var currentContent = Content.Ratings
    
    func changeContent(to content: Content) {
        currentContent = content
        titleCell!.toggleHideButtons(currentContent == .Categories)
        tableView?.reloadData()
    }
    
// MARK: ReloadContent
    func reload() {
        self.tableView?.reloadData()
    }
}
