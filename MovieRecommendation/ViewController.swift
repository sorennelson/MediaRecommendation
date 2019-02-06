//
//  ViewController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/17/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var ratingsTableView: NSTableView!
    var ratingsDataSource = RatingsTableView()
    @IBOutlet var recommendationTableView: NSTableView!
    var recommendationDataSource = RecommendationTableView()
    @IBOutlet var categoriesTableView: NSTableView!
    var categoriesDataSource = CategoriesTableView()

    var expansion = Expansion.notExpanded
    @IBOutlet var recToViewConstraint: NSLayoutConstraint!
    @IBOutlet var recToCategoriesConstraint: NSLayoutConstraint!
    @IBOutlet var ratingsToViewConstraint: NSLayoutConstraint!
    @IBOutlet var ratingsToCategoriesConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViews()
        self.view.window?.backgroundColor = NSColor(red: 0.0898, green: 0.0938, blue: 0.0938, alpha: 1)

        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")

            ParseController.sharedInstance.importAndParseData()
            var RM = ParseController.sharedInstance.importToMLModel()
            HypothesisEvaluation.sharedInstance.trainData(iterations: 300, RM: &RM)
        }

// 0.0008 - too large
// 0.00079 - works
//        runTests()
    }

    private func setupTableViews() {
        ratingsTableView.dataSource = ratingsDataSource
        ratingsTableView.delegate = ratingsDataSource
        ratingsTableView.backgroundColor = NSColor(red: 0.1205, green: 0.1232, blue: 0.1287, alpha: 1)
        ratingsTableView.reloadData()

        recommendationTableView.dataSource = recommendationDataSource
        recommendationTableView.delegate = recommendationDataSource
        recommendationTableView.backgroundColor = NSColor(red: 0.0898, green: 0.0938, blue: 0.0938, alpha: 1)
        recommendationTableView.reloadData()

        categoriesTableView.dataSource = categoriesDataSource
        categoriesTableView.delegate = categoriesDataSource
        categoriesTableView.backgroundColor = NSColor(red: 0.152, green: 0.215, blue: 0.246, alpha: 1)
        // 39 55 63
        categoriesTableView.reloadData()
    }


    private func runTests() {
        let test = Test.sharedInstance
        test.runGradientTests()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}
