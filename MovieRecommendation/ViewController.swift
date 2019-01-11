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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingsTableView.dataSource = ratingsDataSource
        ratingsTableView.delegate = ratingsDataSource
        ratingsTableView.backgroundColor = NSColor(red: 0.1205, green: 0.1232, blue: 0.1287, alpha: 1)
        ratingsTableView.reloadData()
        
        recommendationTableView.dataSource = recommendationDataSource
        recommendationTableView.delegate = recommendationDataSource
        recommendationTableView.backgroundColor = NSColor(red: 0.08493, green: 0.08767, blue: 0.09041, alpha: 1)
        recommendationTableView.reloadData()
        
        categoriesTableView.dataSource = categoriesDataSource
        categoriesTableView.delegate = categoriesDataSource
        categoriesTableView.backgroundColor = NSColor(red: 0.1506, green: 0.1945, blue: 0.2164, alpha: 1)
        categoriesTableView.reloadData()

        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            ImportController.sharedInstance.delegate = GradientDescentController.sharedInstance
            ParseController.sharedInstance.importAndParseData()
            ParseController.sharedInstance.importToMLModel()
            
            let hypothesisEval = HypothesisEvaluation.sharedInstance
            hypothesisEval.delegate = GradientDescentController.sharedInstance
            hypothesisEval.runGradientDescents(iterations: 500)
        }
        

// 0.0008 - too large
// 0.00079 - works
//        runTests()
    }
    
    private func runTests() {
        let test = Test.sharedInstance
        test.delegate = GradientDescentController.sharedInstance
        test.runGradientTests()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

