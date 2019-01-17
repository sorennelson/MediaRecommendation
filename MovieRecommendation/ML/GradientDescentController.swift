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
    
    func runGradientDescent(RM: inout RecommenderModel, lambda: Double, iterations: Int, alpha: Double) -> matrix {
        var trainJ = [Double]()
        RM.theta = RM.originalTheta
        let costFunction = CostFunction(RM: &RM, lambda: lambda)
        
        for _ in 1..<iterations {
            let (J, grad) = costFunction.takeStep()
            RM.theta = RM.theta - (alpha * grad)
            trainJ.append(J)
        }
        
        print("Lambda: \(lambda) Alpha: \(alpha) trainJ: \(trainJ)")
        return RM.theta
    }
    
    func computeTrainSetError(RM: inout RecommenderModel) -> Double {
        let costFunction = CostFunction(RM: &RM, lambda: 0)
        return costFunction.computeTestCost()
    }
    
    func computeTestSetError(RM: inout RecommenderModel) -> Double {
        let costFunction = CostFunction(RM: &RM, lambda: 0)
        return costFunction.computeTestCost()
    }
    
    
    // Mark: TESTING
    func takeStep(RM: inout RecommenderModel, lambda: Double) -> (Double, matrix) {
        let costFunction = CostFunction(RM: &RM, lambda: lambda)
        return costFunction.takeStep()
    }
    
}
