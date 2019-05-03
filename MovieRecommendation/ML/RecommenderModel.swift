//
//  RecommenderModel.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/15/18.
//  Copyright © 2018 SORN. All rights reserved.
//
// https://stsievert.com/swix/matrix.html#module-matrix ~ Swix

import Foundation

enum RMType {
    case ContentBased
    case CollaborativeFiltering
}

class RecommenderModel {
    
    var algorithmType:RMType
    
    // Ratings: Y(movie, user) = 0.5 - 5
    var Y: matrix
    var yTest: matrix
    var yTrain: matrix
    
    // Binary value: R(movie, user) = 1 if rated, 0 if not
    var R: matrix
    var rTest: matrix
    var rTrain: matrix
    
    // Binary value for Content Based: X(movie, genres) = 1 if has that genre, 0 if not
    var X: matrix
    var originalXTrain: matrix
    var originalXTest: matrix
    var xTest: matrix
    var xTrain: matrix
    
    // Trained Parameters
    var originalWeights: matrix
    var weights: matrix
    
    var mediaCount: Int
    var featureCount: Int
    var userCount: Int
    
    var trainCount: Int
    var testCount: Int
    
    /* ----------------------------------------------------------------------------------------------------
     Movie_Data:
     nm: # of movies = 164979
     nu: # of users = 671
     n : # of features = 18 - 0 based
     ---------------------------------------------------------------------------------------------------- */
    
    init() {
        Y = zeros((0,0))
        yTest = zeros((0,0))
        yTrain = zeros((0,0))
        R = zeros((0,0))
        rTest = zeros((0,0))
        rTrain = zeros((0,0))
        X = zeros((0,0))
        originalXTrain = zeros((0,0))
        originalXTest = zeros((0,0))
        xTest = zeros((0,0))
        xTrain = zeros((0,0))
        weights = zeros((0,0))
        originalWeights = zeros((0,0))
        userCount = 0
        mediaCount = 0
        featureCount = 0
        trainCount = 0
        testCount = 0
        algorithmType = .CollaborativeFiltering
    }

    init(mediaCount: Int, userCount: Int, featureCount: Int, type: RMType) {
        self.algorithmType = type
        
        self.mediaCount = mediaCount
        self.userCount = userCount
        self.featureCount = featureCount
        Y = zeros((mediaCount, userCount))
        R = zeros((mediaCount, userCount))
        
        if type == .ContentBased {
            X = zeros((mediaCount, featureCount + 1))
            X[0..<mediaCount, 0] = ones(mediaCount)
            weights = rand((userCount, featureCount + 1))
            weights[0..<userCount, 0] = zeros(userCount)
        }
        else {
            // No bias parameter for collaborative filtering
            // Randomly initialize X for collaborative filtering
            X = rand((mediaCount, featureCount))
            weights = rand((userCount, featureCount))
        }
        originalXTrain = X
        originalXTest = X
        originalWeights = weights
        
        trainCount = 0
        testCount = 0
        
        yTest = zeros((0,0))
        yTrain = zeros((0,0))
        rTest = zeros((0,0))
        rTrain = zeros((0,0))
        xTest = zeros((0,0))
        xTrain = zeros((0,0))
    }
    
    // MARK:  SETTERS
    func setX(matrix: matrix) {
        if (matrix.shape == (mediaCount, featureCount)) {
            X = matrix
        } else {
            print("Matrix has shape: \(matrix.shape) but X should have shape: \(X.shape)")
            //TODO: Error
        }
    }
    
    func setY(matrix: matrix) {
        if (matrix.shape == Y.shape) {
           Y = matrix
        } else {
            print("Matrix has shape: \(matrix.shape) but Y should have shape: \(Y.shape)")
            //TODO: Error
        }
    }
    
    func setR(matrix: matrix) {
        if (matrix.shape == R.shape) {
             R = matrix
        } else {
            print("Matrix has shape: \(matrix.shape) but R should have shape: \(R.shape)")
            //TODO: Error
        }
            
    }
    
    func setWeights(matrix: matrix) {
        if (matrix.shape == (userCount, featureCount)) {
            weights = matrix
        } else {
            print("Matrix has shape: \(matrix.shape) but Theta should have shape: \(weights.shape)")
            //TODO: Error
        }
    }
    
    func setAllMatrices(X: matrix, Y: matrix, R: matrix, Theta: matrix) {
        setX(matrix: X)
        setY(matrix: Y)
        setR(matrix: R)
        setWeights(matrix: Theta)
    }
    
    func resetMatrices() {
        self.weights = originalWeights
        self.xTrain = originalXTrain
//        self.xTest = originalXTest
    }
    
    // MARK: UPDATERS
    func updateX(at row: Int, _ columns: Range<Int>, with features: vector) {
        X[row, columns] = features
    }
    
    func updateRatings(at row: Int, _ column: Int, with rating: Double) {
        Y[row - 1, column - 1] = rating
        R[row - 1, column - 1] = 1
    }
    
    func separateTrainingAndTestData() {
        trainCount = ceil(X.rows.double * 0.7).int
        testCount = X.rows.double - trainCount
        
        updateTrainingSet(xTrain: X[0..<trainCount, 0..<X.columns], yTrain: Y[0..<trainCount, 0..<Y.columns], rTrain: R[0..<trainCount, 0..<R.columns])
        updateTestSet(xTest: X[trainCount..<X.rows, 0..<X.columns], yTest: Y[trainCount..<Y.rows, 0..<Y.columns], rTest: R[trainCount..<R.rows, 0..<R.columns])
    }
    
    func updateTestSet(xTest: matrix, yTest: matrix, rTest: matrix) {
        self.xTest = xTest
        self.originalXTest = xTest
        self.yTest = yTest
        self.rTest = rTest
    }
    
    func updateTrainingSet(xTrain: matrix, yTrain: matrix, rTrain: matrix) {
        self.xTrain = xTrain
        self.originalXTrain = xTrain
        self.yTrain = yTrain
        self.rTrain = rTrain
    }
    
    // MARK: GETTERS
    func getParametersForUser(_ id: Int) -> vector { return weights[id - 1, "all"] }
    
    func getAllMatrices() -> (matrix, matrix, matrix, matrix) {
        return (X, Y, R, weights)
    }
    
    // MARK: PREDICTION
    func predict(media: Int, user: Int) -> Double {
        // normally feature count would be +1
        let t = weights[user, "all"]
        let x = X[media, "all"]
        let prediction = sum (x * t)
        let rounded = round(prediction * 2) / 2
        return rounded
    }
}
    
