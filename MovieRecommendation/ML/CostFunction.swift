//
//  CostFunction.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/24/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class CostFunction {
    
    // TODO: Allow for multiple threads
    private var X: matrix
    private var Y: matrix
    private var R: matrix
    private var theta: matrix
    private var lambda: Double

    init(X: matrix, Y: matrix, R: matrix, theta: matrix, lambda: Double) {
        self.X = X
        self.Y = Y
        self.R = R
        self.theta = theta
        self.lambda = lambda
    }
    
    func update(_ theta: matrix) {
        self.theta = theta
    }
    
    func takeStep() -> (Double, matrix) {
        let error = computeError()
        let grad = computeGrad(error)
        
        let sq_error = error * error
        let J = computeCost(sq_error)
        
        return (J, grad)
    }
    
    private func computeError() -> matrix {
        let allError = X.dot(transpose(theta)) - Y
        return R * allError // to only get the values that are rated
    }
    
    private func computeGrad(_ error: matrix) -> matrix {
        var grad = transpose(error).dot(X)
        if lambda != 0 {
            grad = grad + (lambda * theta)
        }
        return grad
    }
    
    func computeTestCost() -> Double {
        let error = computeError()
        let sq_error = error * error
        return computeCost(sq_error)/(2 * X.rows)
    }
    
    private func computeCost(_ sq_error: matrix) -> Double {
        var J = sum(sq_error.flat) / 2
        if lambda != 0.0 {
            J += (lambda / 2) * sum(pow(theta, power: 2).flat)
        }
        return J
    }
    
}
