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

            ParseController.sharedInstance.importAndParseData()
            var RM = ParseController.sharedInstance.importToMLModel()
            HypothesisEvaluation.sharedInstance.trainData(iterations: 300, RM: &RM)
        }

// 0.0008 - too large
// 0.00079 - works
//        runTests()
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


    private func runTests() {
        let test = Test.sharedInstance
        test.runGradientTests()
    }
}
