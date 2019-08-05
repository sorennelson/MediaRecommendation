//
//  LeftTableView.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 12/18/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class LeftTableView : NSObject, NSTableViewDelegate, NSTableViewDataSource, UpdateContent  {
    
// MARK: TableView
    var tableView: NSTableView?
    let CollectionCellID = "CVCell"
    let MediaCellID = "MediaCellID"
    let TitleCellID = "TitleCell"
    var titleCell: TitleCell?
    var selectedCategoryRow = 0
    var selectedCategory = Genre(name: "All", count: 0)
    
    func setTableView(_ tableView: NSTableView) {
        self.tableView = tableView
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        self.tableView!.backgroundColor = NSColor(red: 0.0898, green: 0.0938, blue: 0.0938, alpha: 1)
        self.tableView!.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if currentContent == .Recommendations {
            guard let category = ObjectController.sharedInstance.getGenre(at: selectedCategoryRow)
                else {  return 1  }
            return 1 + Int(ceil(Double(category.count) / 3.0))
            
        } else if currentContent == .MostRecent {
            return 1 + Int(ceil(Double(ObjectController.sharedInstance.getMostRecentCount()) / 3.0))
            
        } else if currentContent == .MostViewed {
            return 1 + Int(ceil(Double(ObjectController.sharedInstance.getMostViewedCount()) / 3.0))
            
        } else if currentContent == .Series {
            return 1 + Int(ceil(Double(ObjectController.sharedInstance.getSeriesCount()) / 3.0))
            
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch row {
        case 0 :
            return getTitleCellView(tableView: tableView)
            
        default :
            return getMediaCellView(tableView: tableView, row: row-1)
        }
    }
    
    private func getTitleCellView(tableView: NSTableView) -> TitleCell? {
        titleCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: TitleCellID), owner: nil) as? TitleCell
        titleCell!.setHeader(currentContent)
        titleCell!.toggleArrowButtonDirection(ViewController.isExpanded)
        return titleCell
    }
    
    private func getMediaCellView(tableView: NSTableView, row: Int) -> LeftTVMediaCell? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: MediaCellID), owner: nil) as! LeftTVMediaCell
        
        if currentContent == .Recommendations {
            if let media = ObjectController.sharedInstance.getMediaForGenre(withName: selectedCategory.name, for: row*3..<row*3+3) {
                cell.setMedia(media: media)
            }
        } else if currentContent == .MostRecent {
            let media = ObjectController.sharedInstance.getMostRecent(for: row*3..<row*3+3)
            cell.setMedia(media: media)
            
        } else if currentContent == .MostViewed {
            let media = ObjectController.sharedInstance.getMostViewed(for: row*3..<row*3+3)
            cell.setMedia(media: media)
        
        } else if currentContent == .Series {
            if ObjectController.currentMediaType == .Books {
                let series = ObjectController.sharedInstance.getBookSeries(for: row*3..<row*3+3)
                cell.setBookSeries(series: series)
            } else {
                let series = ObjectController.sharedInstance.getMovieSeries(for: row*3..<row*3+3)
                cell.setMovieSeries(series: series)
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == 0 { return 90 }
        return 335
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
        titleCell!.toggleArrowButtonDirection(!ViewController.isExpanded)
        tableView?.reloadData()
    }
    
    func selectedCategory(_ categoryRow: Int, category: Genre) {
        selectedCategoryRow = categoryRow
        selectedCategory = category
        tableView?.scrollRowToVisible(0)
        ObjectController.sharedInstance.getMediaForGenre(withName: selectedCategory.name) { (_) in
            self.tableView?.reloadData()
        }
    }
}
