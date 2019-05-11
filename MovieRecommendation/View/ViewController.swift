//
//  ViewController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/17/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Cocoa
import FirebaseCore
//import FirebaseFirestore

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
        ObjectController.sharedInstance.setupFirebase()
        ObjectController.sharedInstance.checkForUser(completion: { (success) in
            if !success {
                // TODO: Notification -> Try again
            } else {
                self.userLoggedIn()
            }
        })
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViews()
        self.view.layer?.backgroundColor = NSColor(red: 0.0898, green: 0.0938, blue: 0.0938, alpha: 1).cgColor

        DispatchQueue.global(qos: .background).async {
            
//          TODO: Move to OC
            ParseController.sharedInstance.importAndParseMovies()
            DispatchQueue.main.async {
                self.leftTableView.reloadData()
            }
            print("Movies imported")
            
            var collabMovieRM = ParseController.sharedInstance.importToCollaborativeFilteringMLModel(media: ObjectController.sharedInstance.movies, featureCount: 8)
            var err = HypothesisEvaluation.sharedInstance.trainData(iterations: 500, RM: &collabMovieRM)
            print("ROOT MEAN SQUARED ERROR FOR MOVIE COLLABORATIVE FILTERING: " + String(err))
            ObjectController.sharedInstance.movieRM = collabMovieRM

//            var contentMovieRM = ParseController.sharedInstance.importToContentBasedMLModel(media: ObjectController.sharedInstance.movies, featureCount: 18)
//            err = HypothesisEvaluation.sharedInstance.trainData(iterations: 1000, RM: &contentMovieRM)
//            print("ROOT MEAN SQUARED ERROR FOR MOVIE CONTENT BASED: " + String(err))
        }
        
        DispatchQueue.global(qos: .background).async {
            ParseController.sharedInstance.importAndParseBooks()
            DispatchQueue.main.async {
                self.leftTableView.reloadData()
            }
            print("Books imported")

            var collabBookRM = ParseController.sharedInstance.importToCollaborativeFilteringMLModel(media: ObjectController.sharedInstance.books, featureCount: 10)
            var err = HypothesisEvaluation.sharedInstance.trainData(iterations: 500, RM: &collabBookRM)
            print("ROOT MEAN SQUARED ERROR FOR BOOK COLLAB BASED: " + String(err))
            ObjectController.sharedInstance.bookRM = collabBookRM

//            var contentBookRM = ParseController.sharedInstance.importToContentBasedMLModel(media: ObjectController.sharedInstance.books, featureCount: ObjectController.sharedInstance.allBookGenres.count)
//            err = HypothesisEvaluation.sharedInstance.trainData(iterations: 1000, RM: &contentBookRM)
//            print("ROOT MEAN SQUARED ERROR FOR BOOK CONTENT BASED: " + String(err))
        }
        
    }
    
    private func setupTableViews() {
        rightDataSource.setTableView(rightTableView)
        
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
        
    }
    
    override func dismiss(_ viewController: NSViewController) {
        super.dismiss(viewController)
        reloadTableViews()
    }
    
    
    private func runTests() {
        let test = Test.sharedInstance
        test.runGradientTests()
    }
}
