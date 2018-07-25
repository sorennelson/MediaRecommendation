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
    
    private func setSmallValues() {
        delegate?.createEmptyMatrices(movieCount: 5, userCount: 4, featureCount: 3)
        let X = array(1.048686, -0.400232, 1.194119, 0.780851, -0.385626, 0.521198, 0.641509, -0.547854, -0.083796, 0.453618, -0.800218, 0.680481, 0.937538, 0.106090, 0.361953)
        let Y = array(5, 4, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0)
        let R = array(1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
        let theta = array(0.28544, -1.68427, 0.26294, 0.50501, -0.45465, 0.31746, -0.43192, -0.47880, 0.84671, 0.72860, -0.27189, 0.32684)
        
        delegate?.setMatrices(X: X.reshape((5, 3)), Y: Y.reshape((5, 4)), R: R.reshape((5, 4)), Theta: theta.reshape((4, 3)))
    }
    
    func runGradientTests() {
        setSmallValues()
//        testGradientStep()
//        testRegularization()
        testGradientDescent()
    }
    
    private func testGradientStep() {
        let (J, grad) = delegate!.takeStep(lambda: 0)
        print("Your Cost \(J)) \nActual Cost \(22.225)")
        print("Your Grad \(grad) \nActual Grad \(array(-10.56802, 4.62776, -7.16004, -3.05099, 1.16441, -3.47411, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000).reshape((4, 3)))")
    }
    
    func testRegularization() {
        let (J, grad) = delegate!.takeStep(lambda: 1.5)
        print("Your Cost \(J) \nActual Cost \(31.344)")
        print("Your Grad \(grad) \nActual Grad \(array(-10.13985, 2.10136, -6.76564, -2.29347, 0.48244, -2.99791, -0.64787, -0.71821, 1.27007, 1.09290, -0.40784, 0.49027).reshape((4, 3)))")
    }
    
    func testGradientDescent() {
        delegate?.runGradientDescent(iterations: 400, alpha: 0.001)
    }
    

    
    
    
}
