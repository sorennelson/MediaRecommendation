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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingsTableView.dataSource = ratingsDataSource
        ratingsTableView.delegate = ratingsDataSource
        ratingsTableView.reloadData()

        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            let parseController = ParseController.sharedInstance
            parseController.delegate = GradientDescentController.sharedInstance
            parseController.importAndParseData()
            
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

