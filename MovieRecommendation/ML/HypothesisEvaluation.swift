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

    func trainData(iterations: Int, RM: inout RecommenderModel) {
        //TODO: Normalize ratings
        
        RM.separateTrainingAndTestData()
        let lambda = 2.56
        let alpha = 0.0003
        let GD = GradientDescentController.sharedInstance
        
        let _ = GD.runGradientDescent(RM: &RM, lambda: lambda, iterations: iterations, alpha: alpha)
        
        print(GD.computeTrainSetError(RM: &RM))
        print(GD.computeTestSetError(RM: &RM))
        //2.56, 0.003, 1.1984, 200
    }
    
    func findLowestCombination(iterations: Int, RM: inout RecommenderModel) {
//        var thetas = [Double: matrix]()
//        var testErrors = [Double: Double]()
//
//        let lambdas = [0, 0.01, 0.04, 0.08, 0.16, 0.32, 0.64, 1.28, 2.56, 5.12, 10.24]
//        let alphas = [0.0003, 0.004, 0.005]
//        var lowestLambda = 10000000.0
//        var lowestAlpha = 10000000.0
//        var lowestCost = 1000000000.0
//
//        let GD = GradientDescentController.sharedInstance
//
//
//        for alpha in alphas {
//            for lambda in lambdas {
//                thetas[lambda] = GD.runGradientDescent(RM: &RM, lambda: lambda, iterations: iterations, alpha: alpha)
//
//                testErrors[lambda] = GD.computeTestSetError(theta: thetas[lambda]!)
//                print(testErrors[lambda]!)
//                if testErrors[lambda]! < lowestCost {
//                    lowestCost = testErrors[lambda]!
//                    lowestLambda = lambda
//                    lowestAlpha = alpha
//                }
//            }
//        }
//        print(lowestCost)
//        print(lowestLambda)
//        print(lowestAlpha)
    }
    
    
}
