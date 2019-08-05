//
//  ViewController.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 7/17/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var rightTableView: NSTableView!
    var rightDataSource = RightTableView()
    @IBOutlet var leftTableView: NSTableView!
    var leftDataSource = LeftTableView()
    @IBOutlet var categoriesTableView: NSTableView!
    var categoriesDataSource = CategoriesTableView()

    @IBOutlet var userButton: NSButton!
    
    static var isExpanded = false
    @IBOutlet var leftTVToViewConstraint: NSLayoutConstraint!
    @IBOutlet var leftTVToCategoriesConstraint: NSLayoutConstraint!
    @IBOutlet var rightTVToViewConstraint: NSLayoutConstraint!
    @IBOutlet var rightTVToCategoriesConstraint: NSLayoutConstraint!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if let window = self.view.window {
            window.styleMask = [.closable, .titled, .miniaturizable]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserController.sharedInstance.attemptLogin { (success) in
            // TODO: If not logged in, prompt them
            ImportController.sharedInstance.loadMediaRatingsAndGenres(.Movies) { (media, ratings, genres) in
                // TODO: Notification if something didn't load
                self.setupTableViews()
            }
        }
        self.view.layer?.backgroundColor = NSColor(red: 0.0898, green: 0.0938, blue: 0.0938, alpha: 1).cgColor
    }
    
    private func setupTableViews() {
        rightDataSource.setTableView(rightTableView)
        rightDataSource.contentDelegate = leftDataSource
        
        leftDataSource.setTableView(leftTableView)

        categoriesTableView.dataSource = categoriesDataSource
        categoriesTableView.delegate = categoriesDataSource
        categoriesDataSource.contentDelegate = leftDataSource
        categoriesTableView.backgroundColor = NSColor(red: 0.152, green: 0.215, blue: 0.246, alpha: 1)
        categoriesTableView.reloadData()
    }
    
    func reloadTableViews() {
        DispatchQueue.main.async {
            self.rightTableView.reloadData()
            self.leftTableView.reloadData()
            self.categoriesTableView.reloadData()
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {}
    
    @IBAction func bookButtonPressed(_ sender: Any) {
        ImportController.sharedInstance.loadMediaRatingsAndGenres(.Books) { (media, ratings, genres) in
            // TODO: Notification if something didn't load
            ObjectController.currentMediaType = .Books
            self.reloadTableViews()
        }
    }
    
    @IBAction func movieButtonPressed(_ sender: Any) {
        ObjectController.currentMediaType = .Movies
        reloadTableViews()
    }
    
    @IBAction func userButtonPressed(_ sender: Any) {
        if User.current == nil {
            performSegue(withIdentifier: "Authentication", sender: self)
        } else {
            performSegue(withIdentifier: "Logout", sender: sender)
        }
    }
    
    override func dismiss(_ viewController: NSViewController) {
        super.dismiss(viewController)
        reloadTableViews()
    }
}
