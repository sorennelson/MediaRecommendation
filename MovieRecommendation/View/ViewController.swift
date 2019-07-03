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
//        ObjectController.sharedInstance.checkForUser(completion: { (success) in
//            if !success {
//                // TODO: Notification -> Try again
//            } else {
//                self.userLoggedIn()
//            }
//        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViews()
        self.view.layer?.backgroundColor = NSColor(red: 0.0898, green: 0.0938, blue: 0.0938, alpha: 1).cgColor

        ImportController.sharedInstance.loadAllMedia(.Books, completion: { str in
            print(str)
        })
        
        ImportController.sharedInstance.loadAllMedia(.Movies, completion: { str in
            print(str)
        })
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
        reloadTableViews()
    }
    
    func reloadTableViews() {
        rightTableView.reloadData()
        leftTableView.reloadData()
        categoriesTableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func bookButtonPressed(_ sender: Any) {
        // TODO: Check if books have been imported
        ObjectController.currentMediaType = .Books
        reloadTableViews()
    }
    
    @IBAction func movieButtonPressed(_ sender: Any) {
        ObjectController.currentMediaType = .Movies
        reloadTableViews()
    }
    
    @IBAction func userButtonPressed(_ sender: Any) {
        if User.current != nil {
            performSegue(withIdentifier: "Authentication", sender: sender)
        } else {
            performSegue(withIdentifier: "Logout", sender: sender)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Authentication":
            print("Auth")
        case "Logout":
            print("Logout")
        default:
            print("")
        }
    }
    
    override func dismiss(_ viewController: NSViewController) {
        super.dismiss(viewController)
        reloadTableViews()
    }
    
    
    private func runTests() {
        let test = Test.sharedInstance
    }
}
