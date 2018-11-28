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
    
    func getParametersForUser(_ id: Int) -> vector { return RM.theta[id - 1, "all"] }
    
    func getMatrices() -> (matrix, matrix, matrix, matrix) {
        return (RM.X, RM.Y, RM.R, RM.theta)
    }
    
    func updateX(at row: Int, _ columns: Range<Int>, with features: vector) {
        self.RM.X[row, columns] = features
    }
    
    func updateRatings(at row: Int, _ column: Int, with rating: Double) {
        RM.Y[row - 1, column - 1] = rating
        RM.R[row - 1, column - 1] = 1
    }
    
    func updateTestSet(xTest: matrix, yTest: matrix, rTest: matrix) {
        RM.xTest = xTest
        RM.yTest = yTest
        RM.rTest = rTest
    }
    
    func updateTrainingSet(xTrain: matrix, yTrain: matrix, rTrain: matrix) {
        RM.xTrain = xTrain
        RM.yTrain = yTrain
        RM.rTrain = rTrain
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

    func runGradientDescent(lambda: Double, iterations: Int, alpha: Double) -> matrix {
        var trainJ = [Double]()
        RM.theta = RM.originalTheta
        let costFunction = CostFunction(X: RM.xTrain, Y: RM.yTrain, R: RM.rTrain, theta: RM.theta, lambda: lambda)
        
        for _ in 1..<iterations {
            let (J, grad) = takeStep(costFunction)
            RM.theta = RM.theta - (alpha * grad)
            costFunction.update(RM.theta)
            trainJ.append(J)
        }
        
        print("Lambda: \(lambda) Alpha: \(alpha) trainJ: \(trainJ)")
        return RM.theta
    }
    
    private func takeStep(_ costFunction: CostFunction) -> (Double, matrix) {
        return costFunction.takeStep()
    }
    
    func takeStep(lambda: Double) -> (Double, matrix) {
        let costFunction = CostFunction(X: RM.X, Y: RM.Y, R: RM.R, theta: RM.theta, lambda: lambda)
        return costFunction.takeStep()
    }
    
    func computeTrainSetError(theta: matrix) -> Double {
        let costFunction = CostFunction(X: RM.xTrain, Y: RM.yTrain, R: RM.rTrain, theta: theta, lambda: 0)
        return costFunction.computeTestCost()
    }
    
    func computeTestSetError(theta: matrix) -> Double {
        let costFunction = CostFunction(X: RM.xTest, Y: RM.yTest, R: RM.rTest, theta: theta, lambda: 0)
        return costFunction.computeTestCost()
    }

    func predict(movie: Int, user: Int) -> Double {
        return RM.predict(movie: movie, user: user)
    }
    
    
}
