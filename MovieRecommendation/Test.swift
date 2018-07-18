//
//  TestController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/17/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class Test {
    
    static var sharedInstance = Test()
    let parseController = ParseController.sharedInstance
    var delegate: RMDelegate?
    
    func runGradientTests() {
        testGradientStep()
    }
    
    func testGradientStep() {
        setSmallValues()
        delegate?.takeStep()
        print(delegate!.getCost())
        print(delegate!.getGrad())
    }
    
    private func setSmallValues() {
        delegate?.runGradientDescent(movieCount: 5, userCount: 3, featureCount: 3)
        let X = array(1.048686, -0.400232, 1.194119, 0.780851, -0.385626, 0.521198, 0.641509, -0.547854, -0.083796, 0.453618, -0.800218, 0.680481, 0.937538, 0.106090, 0.361953)
        delegate!.setX(matrix: X.reshape((5,3)))
        
        let theta = array(0.28544, -1.68427, 0.26294, 0.50501, -0.45465, 0.31746, -0.43192, -0.47880, 0.84671, 0.72860, -0.27189, 0.32684)
        delegate?.setTheta(matrix: theta.reshape((4, 3)))
        
        let Y = array(5, 4, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0)
        delegate?.setY(matrix: Y.reshape((5, 4)))
        
        let R = array(1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
        delegate?.setR(matrix: R.reshape((4, 3)))
    }
    
    
    
}
