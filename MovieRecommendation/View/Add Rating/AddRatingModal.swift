//
//  AddRatingModal.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 4/20/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class AddRatingModal: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate {
    
    @IBOutlet var saveButton: NSButton!
    @IBOutlet var searchField: NSSearchField!
    @IBOutlet var tableView: NSTableView!
    var searchResults = [Media]()
    let CellID = "AddRatingCell"
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) { }
    func searchFieldDidEndSearching(_ sender: NSSearchField) { }
    
    func controlTextDidChange(_ obj: Notification) {
        updateResults(stringValue: self.searchField.stringValue.lowercased(), completion: {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    func updateResults(stringValue: String, completion:@escaping() -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.searchResults = ObjectController.sharedInstance.getAllMedia().values.filter {
                return $0.title.lowercased().contains(stringValue)
            }
            print(self.searchResults.count)
            completion()
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let resultsCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellID), owner: nil) as? AddRatingTVCell
        if searchResults.count > 0 && searchResults.count > row {
            resultsCell!.media = searchResults[row]
        }
//        else {
//            resultsCell!.media = ObjectController.sharedInstance.books[row]
//        }
        return resultsCell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if searchResults.count > 0 {
            return searchResults.count
        }
        return 0

    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 140
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        ObjectController.sharedInstance.doneAddingRatings()
        presentingViewController?.dismiss(self)
    }
}
