//
//  HypothesisEvaluation.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/27/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class HypothesisEvaluation {
    
    static let sharedInstance = HypothesisEvaluation()
    var delegate: RMDelegate?

    func runGradientDescents(iterations: Int) {
        //TODO: Normalize ratings
        
        let (X, Y, R, _) = delegate!.getMatrices()
        separate(X: X, Y: Y, R: R)
        let lambda = 2.56
        let alpha = 0.0003
        
        let theta = delegate?.runGradientDescent(lambda: lambda, iterations: 3000, alpha: alpha)
        
        print(delegate!.computeTrainSetError(theta: theta!))
        print(delegate!.computeTestSetError(theta: theta!))
        //2.56, 0.003, 1.1984, 200
    }
    
    func findLowestCombination(iterations: Int) {
        var thetas = [Double: matrix]()
        var testErrors = [Double: Double]()

        let lambdas = [0, 0.01, 0.04, 0.08, 0.16, 0.32, 0.64, 1.28, 2.56, 5.12, 10.24]
        let alphas = [0.0003, 0.004, 0.005]
        var lowestLambda = 10000000.0
        var lowestAlpha = 10000000.0
        var lowestCost = 1000000000.0
        
        for alpha in alphas {
            for lambda in lambdas {
                thetas[lambda] = delegate?.runGradientDescent(lambda: lambda, iterations: iterations, alpha: alpha)
                
                testErrors[lambda] = delegate!.computeTestSetError(theta: thetas[lambda]!)
                print(testErrors[lambda]!)
                if testErrors[lambda]! < lowestCost {
                    lowestCost = testErrors[lambda]!
                    lowestLambda = lambda
                    lowestAlpha = alpha
                }
            }
        }
        print(lowestCost)
        print(lowestLambda)
        print(lowestAlpha)
    }
    
    private func separate(X: matrix, Y: matrix, R: matrix) {
        let trainCount = ceil(X.rows.double * 0.7).int
        
        delegate?.updateTrainingSet(xTrain: X[0..<trainCount, 0..<X.columns], yTrain: Y[0..<trainCount, 0..<Y.columns], rTrain: R[0..<trainCount, 0..<R.columns])
        delegate?.updateTestSet(xTest: X[trainCount..<X.rows, 0..<X.columns], yTest: Y[trainCount..<Y.rows, 0..<Y.columns], rTest: R[trainCount..<R.rows, 0..<R.columns])
    }
    
    
    
}
