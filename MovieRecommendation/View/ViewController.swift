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

    var isExpanded = false
    @IBOutlet var leftTVToViewConstraint: NSLayoutConstraint!
    @IBOutlet var leftTVToCategoriesConstraint: NSLayoutConstraint!
    @IBOutlet var rightTVToViewConstraint: NSLayoutConstraint!
    @IBOutlet var rightTVToCategoriesConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViews()
        self.view.layer?.backgroundColor = NSColor(red: 0.0898, green: 0.0938, blue: 0.0938, alpha: 1).cgColor
        //self.view.window?.backgroundColor = NSColor(red: 0.0898, green: 0.0938, blue: 0.0938, alpha: 1)

        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
//          TODO: Move to OC
            
            ParseController.sharedInstance.importAndParseMovies()
            DispatchQueue.main.async {
                self.leftTableView.reloadData()
            }
            print("movies imported")

//            var contentMovieRM = ParseController.sharedInstance.importToContentBasedMLModel(media: ObjectController.sharedInstance.movies, featureCount: 18)
//            HypothesisEvaluation.sharedInstance.trainData(iterations: 300, RM: &contentMovieRM)

            var collabMovieRM = ParseController.sharedInstance.importToCollaborativeFilteringMLModel(media: ObjectController.sharedInstance.movies, featureCount: 7)
            HypothesisEvaluation.sharedInstance.trainData(iterations: 100, RM: &collabMovieRM)
            ObjectController.sharedInstance.movieRM = collabMovieRM
            
            
            ParseController.sharedInstance.importAndParseBooks()
            print("Books imported")

            
//            var bookRM = ParseController.sharedInstance.importToContentBasedMLModel(media: ObjectController.sharedInstance.books, featureCount: ObjectController.sharedInstance.allBookGenres.count)
//            HypothesisEvaluation.sharedInstance.trainData(iterations: 1, RM: &bookRM)
            
//            var collabMovieRM = ParseController.sharedInstance.importToCollaborativeFilteringMLModel(media: ObjectController.sharedInstance.books, featureCount: 7)
//            HypothesisEvaluation.sharedInstance.trainData(iterations: 300, RM: &collabMovieRM)
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
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func bookButtonPressed(_ sender: Any) {
        ObjectController.currentMediaType = .Books
        rightTableView.reloadData()
        leftTableView.reloadData()
    }
    
    @IBAction func movieButtonPressed(_ sender: Any) {
        ObjectController.currentMediaType = .Movies
        rightTableView.reloadData()
        leftTableView.reloadData()
    }
    
    
    
    private func runTests() {
        let test = Test.sharedInstance
        test.runGradientTests()
    }
}
