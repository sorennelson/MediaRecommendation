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
    func getGrad() -> matrix { return RM.grad }
    func getParametersForUser(_ id: Int) -> vector { return RM.theta[id - 1, "all"] }
    
    func updateX(at row: Int, _ columns: Range<Int>, with features: vector) {
        self.RM.X[row, columns] = features
    }
    
    func updateRatings(at row: Int, _ column: Int, with rating: Double) {
        RM.Y[row - 1, column - 1] = rating
        RM.R[row - 1, column - 1] = 1
    }
    
    func createEmptyMatrices(movieCount: Int, userCount: Int, featureCount: Int) {
        test = Test.sharedInstance
        RM = RecommenderModel(movieCount: movieCount, userCount: userCount, featureCount: featureCount)
    }
    
    func setMatrices(X: matrix, Y: matrix, R: matrix, Theta: matrix) {
        RM.setX(matrix: X)
        RM.setY(matrix: Y)
        RM.setR(matrix: R)
        RM.setTheta(matrix: Theta)
    }
    
    // MARK: Algorithm
    
    func runGradientDescent(iterations:Int, alpha: Double) {
        //TODO: Normalize ratings
        var Jhist = [Double]()
        let time = Date.init()
        
        for _ in 1..<iterations {
            let (J, grad) = takeStep(lambda: 10)
            RM.theta = RM.theta - (alpha * grad)
            Jhist.append(J)
        }
        
        print(Date().timeIntervalSince(time))
        print(Jhist)
    }
    
    func takeStep(lambda: Double) -> (Double, matrix) {
        let costFunction = CostFunction(X: RM.X, Y: RM.Y, R: RM.R, theta: RM.theta, lambda: lambda)
        return costFunction.takeStep()
    }
    
    
    
}
