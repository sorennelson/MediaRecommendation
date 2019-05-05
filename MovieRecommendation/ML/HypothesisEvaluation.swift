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

    func trainData(iterations: Int, RM: inout RecommenderModel) -> Double {
        
        let regParam = 0.05
        let learningRate = 0.0001
        let GD = GradientDescentController.sharedInstance
        
        let _ = GD.runBatchGradientDescent(RM: &RM, regParam: regParam, iterations: iterations, learningRate: learningRate)
        
        return GD.computeError(RM: &RM)
    }
    
    func findLowestCombination(iterations: Int, RM: inout RecommenderModel) {
        var weights = [Double: matrix]()
        var errors = [Double: Double]()

        let regParams = [0, 0.01, 0.05, 0.1, 0.5, 1, 5, 10]
        let learningRates = [0.0003, 0.004, 0.005]
        var lowestReg = 10000000.0
        var lowestLearnRate = 10000000.0
        var lowestCost = 1000000000.0

        let GD = GradientDescentController.sharedInstance


        for learningRate in learningRates {
            for regParam in regParams {
                weights[regParam] = GD.runBatchGradientDescent(RM: &RM, regParam: regParam, iterations: iterations, learningRate: learningRate)

                errors[regParam] = GD.computeError(RM: &RM)
                print(errors[regParam]!)
                if errors[regParam]! < lowestCost {
                    lowestCost = errors[regParam]!
                    lowestReg = regParam
                    lowestLearnRate = learningRate
                }
            }
        }
        print(lowestCost)
        print(lowestReg)
        print(lowestLearnRate)
    }
    
    
}
