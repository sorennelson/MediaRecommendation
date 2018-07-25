//
//  ViewController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/17/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let parseController = ParseController.sharedInstance
        parseController.delegate = GradientDescentController.sharedInstance
        parseController.importAndParseData()
        parseController.delegate?.runGradientDescent(iterations: 30, alpha: 0.0001)
        // just tried 0.001
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

