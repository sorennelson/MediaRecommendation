//
//  GradientDescent.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/15/18.
//  Copyright © 2018 SORN. All rights reserved.
//
// https://stsievert.com/swix/matrix.html#module-matrix ~ Swix

import Foundation

class GradientDescent {
    
    static let sharedInstance = GradientDescent()
    let parseController = ParseController.sharedInstance
    // var unrolledTheta: matrix = matrix(columns: 1, rows: 671*19)
    // var unrolledX: matrix = matrix(columns: 1, rows: 164979*19)
    
    // TODO: Set to multiple values. Look through Large Scale Machine Learning
    let alpha = 0
    let lambda = 0
    
    var J = 0
    var xGrad: matrix = zeros((164979, 671))
    var thetaGrad: matrix = zeros((671, 19))
    
//    func unroll() {
//        let flat = parseController.theta.flat
//        unrolledTheta[0, "all"] = flat
//
//        let flatX = parseController.X.flat
//        unrolledX[0, "all"] = flatX
//    }
    
    func runGradientDescentStep() {
        let error = computeError()
        let sq_error = error * error
        computeCost(sq_error)
        computeTheta(error)
    }
    
    private func computeError() -> matrix{
        let allError = parseController.X.dot(transpose(parseController.theta)) - parseController.Y
        return parseController.R * allError // to only get the values that are rated
    }
    
    private func computeCost(_ sq_error: matrix) {
        J = sum(sq_error.flat) / 2
        // Regularization: + sum((lambda / 2) * sum(Theta.^2))
    }
    
    private func computeTheta(_ error: matrix) {
        thetaGrad = transpose(error).dot(parseController.X)
        // Regularization: + lambda * unrolledTheta
    }
    
//    func testGradientStep() {
//        let parseController = ParseController.sharedInstance
//        let xArray = array(1.048686, -0.400232, 1.194119, 0.780851, -0.385626, 0.521198, 0.641509, -0.547854, -0.083796, 0.453618, -0.800218, 0.680481, 0.937538, 0.106090, 0.361953)
//        parseController.X = xArray.reshape((5,3))
//        
//        
//        
//    }
    
    
}
