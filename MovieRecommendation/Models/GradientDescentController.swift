//
//  GradientDescentController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/17/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class GradientDescentController: RMDelegate {
    
    static var sharedInstance = GradientDescentController()
    var test: Test?
    private var RM: RecommenderModel = RecommenderModel()
    
    // MARK: RecommenderModelProtocol
    
    func getCost() -> Double { return RM.J }
    func getGrad() -> matrix { return RM.thetaGrad }
    func getParametersForUser(_ id: Int) -> vector { return RM.theta[id - 1, "all"] }
    
    func setX(matrix: matrix) { RM.X = matrix }
    func setY(matrix: matrix) { RM.Y = matrix }
    func setR(matrix: matrix) { RM.R = matrix }
    func setTheta(matrix: matrix) { RM.theta = matrix }
    
    func updateX(at row: Int, _ columns: Range<Int>, with features: vector) {
        self.RM.X[row, columns] = features
    }
    
    func updateRatings(at row: Int, _ column: Int, with rating: Double) {
        RM.Y[row - 1, column - 1] = rating
        RM.R[row - 1, column - 1] = 1
    }
    
    func runGradientDescent(movieCount: Int, userCount: Int, featureCount: Int) {
        test = Test.sharedInstance
        RM = RecommenderModel(movieCount: movieCount, userCount: userCount, featureCount: featureCount)
        // For now
        takeStep()
    }
    
    // MARK: Algorithm
    
    //    func unroll() {
    //        let flat = parseController.theta.flat
    //        unrolledTheta[0, "all"] = flat
    //
    //        let flatX = parseController.X.flat
    //        unrolledX[0, "all"] = flatX
    //    }
    
    
    func takeStep() {
        let error = computeError()
        computeTheta(error)
        
        let sq_error = error * error
        computeCost(sq_error)
    }
    
    private func computeError() -> matrix {
        let allError = RM.X.dot(transpose(RM.theta)) - RM.Y
        return RM.R * allError // to only get the values that are rated
    }
    
    private func computeCost(_ sq_error: matrix) {
        RM.J = sum(sq_error.flat) / 2
        // Regularization: + sum((lambda / 2) * sum(Theta.^2))
    }
    
    private func computeTheta(_ error: matrix) {
        RM.thetaGrad = transpose(error).dot(RM.X)
        // Regularization: + lambda * unrolledTheta
    }
    
}
