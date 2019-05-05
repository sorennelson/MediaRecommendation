//
//  GradientDescentController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/17/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class GradientDescentController {
    
    static var sharedInstance = GradientDescentController()
    // var test: Test?
    
    func runBatchGradientDescent(RM: inout RecommenderModel, regParam: Double, iterations: Int, learningRate: Double) -> matrix {
        var costs = [Double]()
        RM.resetMatrices()
//        RM.weights = RM.originalWeights

        let costFunction = CostFunction(RM: RM, regParam: regParam)
        
        for _ in 1..<iterations {
            var cost: Double
            
            if RM.algorithmType == .ContentBased {
                cost = takeContentStep(RM: &RM, costFunction: costFunction, learningRate: learningRate)
            }
                
            else {
                cost = takeCollaborativeStep(RM: &RM, costFunction: costFunction, learningRate: learningRate)
            }
            costs.append(cost)
        }
        
        print("Lambda: \(regParam) Alpha: \(learningRate) trainJ: \(costs)")
        return RM.weights
    }
    
    func takeContentStep(RM: inout RecommenderModel, costFunction: CostFunction, learningRate: Double) -> Double {
        let (cost, grad) = costFunction.computeContentStep()
        RM.weights = RM.weights - (learningRate * grad)
        return cost
    }
    
    func takeCollaborativeStep(RM: inout RecommenderModel, costFunction: CostFunction, learningRate: Double) -> Double {
        let (cost, weightGrad, itemFeatureGrad) = costFunction.computeCollaborativeStep()
        
        RM.weights = RM.weights - (learningRate * weightGrad)
        RM.X = RM.X - (learningRate * itemFeatureGrad)
        return cost
    }
    
    func computeError(RM: inout RecommenderModel) -> Double {
        let costFunction = CostFunction(RM: RM, regParam: 0)
        return costFunction.computeTrainError()
    }
    
    
    // MARK: TESTING
//    func takeStep(RM: inout RecommenderModel, lambda: Double) -> (Double, matrix) {
//        let costFunction = CostFunction(RM: &RM, regParam: lambda)
//        return costFunction.computeStep()
//    }
    
}
