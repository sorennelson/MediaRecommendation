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
    private var RM: RecommenderModel
    private var lambda: Double
    

    init(RM: inout RecommenderModel, lambda: Double) {
        self.RM = RM
        self.lambda = lambda
    }
    
    func takeStep() -> (Double, matrix) {
        let error = computeError()
        let grad = computeGrad(error)
        
        let sq_error = error * error
        let J = computeCost(sq_error)
        
        return (J, grad)
    }
    
    private func computeError() -> matrix {
        let allError = RM.X.dot(transpose(RM.theta)) - RM.Y
        return RM.R * allError // to only get the values that are rated
    }
    
    private func computeGrad(_ error: matrix) -> matrix {
        var grad = transpose(error).dot(RM.X)
        if lambda != 0 {
            grad = grad + (lambda * RM.theta)
        }
        return grad
    }
    
    func computeTestCost() -> Double {
        let error = computeError()
        let sq_error = error * error
        return computeCost(sq_error)/(2 * RM.X.rows)
    }
    
    private func computeCost(_ sq_error: matrix) -> Double {
        var J = sum(sq_error.flat) / 2
        if lambda != 0.0 {
            J += (lambda / 2) * sum(pow(RM.theta, power: 2).flat)
        }
        return J
    }
    
}
