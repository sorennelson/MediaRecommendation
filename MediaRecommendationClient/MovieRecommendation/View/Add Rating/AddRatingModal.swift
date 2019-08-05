//
//  AddRatingModal.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 4/20/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class AddRatingModal: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate {
    
    @IBOutlet var saveButton: NSButton!
    @IBOutlet var button5: NSButton!
    @IBOutlet var button4: NSButton!
    @IBOutlet var button3: NSButton!
    @IBOutlet var button2: NSButton!
    @IBOutlet var button1: NSButton!
    
    @IBOutlet var bottomTVConstraint: NSLayoutConstraint!
    
    @IBOutlet var searchField: NSSearchField!
    @IBOutlet var tableView: NSTableView!
    var searchResults = [Media]()
    let CellID = "AddRatingCell"
    
    var rating = 0
    var selectedMedia: Media?
    
    
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
            self.searchResults = ObjectController.sharedInstance.getAllMedia().filter {
                return $0.title.lowercased().contains(stringValue)
            }
            completion()
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let resultsCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellID), owner: nil) as? AddRatingTVCell
        if searchResults.count > 0 && searchResults.count > row {
            resultsCell!.media = searchResults[row]
        }
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
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let cell = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! AddRatingTVCell
        guard let media = cell.media  else  {  return false  }

        selectedMedia = media
        bottomTVConstraint.constant = 60.0
        resetStates(except: 0)
        return true
    }
    
    @IBAction func button5Pressed(_ sender: Any) {
        resetStates(except: 5)
        rating = 5
    }
    
    @IBAction func button4Pressed(_ sender: Any) {
        resetStates(except: 4)
        rating = 4
    }
    
    @IBAction func button3Pressed(_ sender: Any) {
        resetStates(except: 3)
        rating = 3
    }
    
    @IBAction func button2Pressed(_ sender: Any) {
        resetStates(except: 2)
        rating = 2
    }
    
    @IBAction func button1Pressed(_ sender: Any) {
        resetStates(except: 1)
        rating = 1
    }
    
    private func resetStates(except exception: Int) {
        if exception != 5 {
            button5.state = .off
        }
        if exception != 4 {
            button4.state = .off
        }
        if exception != 3 {
            button3.state = .off
        }
        if exception != 2 {
            button2.state = .off
        }
        if exception != 1 {
            button1.state = .off
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        resetStates(except: 0)
        bottomTVConstraint.constant = 0.0
        tableView.deselectAll(self)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let selectedMedia = selectedMedia else { return }
        ObjectController.sharedInstance.addRating(Float(rating), for: selectedMedia, completion: { (success, err) in

        })
        presentingViewController?.dismiss(self)
    }
    
}
