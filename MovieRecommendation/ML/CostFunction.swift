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
    private var regParam: Double
    

    init(RM: RecommenderModel, regParam: Double) {
        self.RM = RM
        self.regParam = regParam
    }
    
//    Root Mean Squared Error
    func computeTrainError() -> Double {
        let error = computeError(data: RM.xTrain, ratings: RM.yTrain, rated: RM.rTrain)
        let sqError = error * error
        let rmse = sqrt(sum(sqError.flat) / Double(error.count))
        return rmse
    }
    
//    Root Mean Squared Error
    func computeTestError() -> Double {
        let error = computeError(data: RM.xTest, ratings: RM.yTest, rated: RM.rTest)
        let sqError = error * error
        let rmse = sqrt(sum(sqError.flat) / Double(error.count))
        return rmse
    }
    
    private func computeError(data: matrix, ratings: matrix, rated: matrix) -> matrix {
        let allError = data.dot(transpose(RM.weights)) - ratings
        return rated * allError // to only get the values that are rated
    }
    
    
//    MARK: Content
    func computeContentStep() -> (Double, matrix) {
        let error = computeError(data: RM.xTrain, ratings: RM.yTrain, rated: RM.rTrain)
        let grad = computeContentWeightGrad(error)
        
        let sq_error = error * error
        let cost = computeContentCost(sq_error)
        
        return (cost, grad)
    }
    
    private func computeContentWeightGrad(_ error: matrix) -> matrix {
        var grad = transpose(error).dot(RM.xTrain)
        let regularization = regParam * RM.weights
        var weightGrad = grad + regularization
        
        weightGrad[0, "all"] = grad[0, "all"] - regParam *  RM.weights[0, "all"] // Don't regularize the regularization parameter
        return grad + regularization
    }
    
    private func computeContentCost(_ sq_error: matrix) -> Double {
        let cost = sum(sq_error.flat) / 2
        let regularization = (regParam / 2) * sum(pow(RM.weights, power: 2).flat)
        
        return cost + regularization
    }
    
    
//    MARK: Collaborative
    func computeCollaborativeStep() -> (Double, matrix, matrix) {
        let error = computeError(data: RM.xTrain, ratings: RM.yTrain, rated: RM.rTrain)
        let itemFeatureGrad = computeCollaborativeItemFeatureGrad(error)
        let weightGrad = computeCollaborativeWeightGrad(error)
        
        let sq_error = error * error
        let cost = computeCollaborativeCost(sq_error)
        
        return (cost, weightGrad, itemFeatureGrad)
    }
    
    private func computeCollaborativeItemFeatureGrad(_ error: matrix) -> matrix {
        let grad = error.dot(RM.weights)
        let regularization = regParam * RM.xTrain
        
        return grad + regularization
    }
    
    private func computeCollaborativeWeightGrad(_ error: matrix) -> matrix {
        let grad = transpose(error).dot(RM.xTrain)
        let regularization = regParam * RM.weights
        
        return grad + regularization
    }
    
    private func computeCollaborativeCost(_ sq_error: matrix) -> Double {
        let cost = sum(sq_error.flat) / 2
        let itemFeatureReg = (regParam / 2) * sum( pow(RM.xTrain, power: 2).flat)
        let weightReg = (regParam / 2) * sum(pow(RM.weights, power: 2).flat)
        
        return cost + itemFeatureReg + weightReg
    }
    
}
