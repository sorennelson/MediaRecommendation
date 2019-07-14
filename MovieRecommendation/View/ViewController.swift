//
//  ViewController.swift
//  MovieRecommendation
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
    
    override func loadView() {
        super.loadView()
        
        UserController.sharedInstance.attemptLogin { (success) in
            // TODO: If not logged in, prompt them
            ImportController.sharedInstance.loadMediaAndRatings(.Movies) { (media, ratings) in
            // TODO: Notification if something didn't load
                self.reloadTableViews()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViews()
        self.view.layer?.backgroundColor = NSColor(red: 0.0898, green: 0.0938, blue: 0.0938, alpha: 1).cgColor
    }
    
    private func setupTableViews() {
        rightDataSource.setTableView(rightTableView)
        rightDataSource.contentDelegate = leftDataSource
        
        leftDataSource.setTableView(leftTableView)

        categoriesTableView.dataSource = categoriesDataSource
        categoriesTableView.delegate = categoriesDataSource
        categoriesTableView.backgroundColor = NSColor(red: 0.152, green: 0.215, blue: 0.246, alpha: 1)
        // 39 55 63
        categoriesTableView.reloadData()
    }
    
    
    private func userLoggedIn() {
        // TODO: edit sign in page
        // TODO: Load user ratings / predictions
        reloadTableViews()
    }
    
    func reloadTableViews() {
        rightTableView.reloadData()
        leftTableView.reloadData()
        categoriesTableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {}
    
    @IBAction func bookButtonPressed(_ sender: Any) {
        ImportController.sharedInstance.loadMediaAndRatings(.Books) { (media, ratings) in
            // TODO: Notification if something didn't load
            self.reloadTableViews()
        }
        ObjectController.currentMediaType = .Books
        reloadTableViews()
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
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
//        switch segue.identifier {
//        case "Authentication":
//            let popoverViewController = segue.destinationController as! AuthenticationViewController
//            print("Auth")
//
//        case "Logout":
//            print("Logout")
//
//        default:
//            print("")
//        }
    }
    
    override func dismiss(_ viewController: NSViewController) {
        super.dismiss(viewController)
        reloadTableViews()
    }
    
//    private func runTests() {
//        let test = Test.sharedInstance
//    }
}
