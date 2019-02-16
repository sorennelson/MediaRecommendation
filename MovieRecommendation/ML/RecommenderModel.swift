//
//  RecommenderModel.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/15/18.
//  Copyright © 2018 SORN. All rights reserved.
//
// https://stsievert.com/swix/matrix.html#module-matrix ~ Swix

import Foundation

struct RecommenderModel {
    
    // Ratings: Y(movie, user) = 0.5 - 5
    var Y: matrix
    var yTest: matrix
    var yTrain: matrix
    
    // Binary value: R(movie, user) = 1 if rated, 0 if not
    var R: matrix
    var rTest: matrix
    var rTrain: matrix
    
    // Binary value: X(movie, genres) = 1 if has that genre, 0 if not
    var X: matrix
    var xTest: matrix
    var xTrain: matrix
    
    // Trained Parameters
    var originalTheta: matrix
    var theta: matrix
    
    var movieCount: Int
    var featureCount: Int
    var userCount: Int
    
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
        xTest = zeros((0,0))
        xTrain = zeros((0,0))
        theta = zeros((0,0))
        originalTheta = zeros((0,0))
        userCount = 0
        movieCount = 0
        featureCount = 0
    }

    init(movieCount: Int, userCount: Int, featureCount: Int) {
        self.movieCount = movieCount
        self.userCount = userCount
        self.featureCount = featureCount
        Y = zeros((movieCount, userCount))
        R = zeros((movieCount, userCount))
        X = zeros((movieCount, featureCount + 1))
        theta = rand((userCount, featureCount + 1))
        originalTheta = theta
        
        yTest = zeros((0,0))
        yTrain = zeros((0,0))
        rTest = zeros((0,0))
        rTrain = zeros((0,0))
        xTest = zeros((0,0))
        xTrain = zeros((0,0))
    }
    
    // MARK:  SETTERS
    mutating func setX(matrix: matrix) {
        if (matrix.shape == (movieCount, featureCount)) {
            X = matrix
        } else {
            print("Matrix has shape: \(matrix.shape) but X should have shape: \(X.shape)")
            //TODO: Error
        }
    }
    
    mutating func setY(matrix: matrix) {
        if (matrix.shape == Y.shape) {
           Y = matrix
        } else {
            print("Matrix has shape: \(matrix.shape) but Y should have shape: \(Y.shape)")
            //TODO: Error
        }
    }
    
    mutating func setR(matrix: matrix) {
        if (matrix.shape == R.shape) {
             R = matrix
        } else {
            print("Matrix has shape: \(matrix.shape) but R should have shape: \(R.shape)")
            //TODO: Error
        }
            
    }
    
    mutating func setTheta(matrix: matrix) {
        if (matrix.shape == (userCount, featureCount)) {
            theta = matrix
        } else {
            print("Matrix has shape: \(matrix.shape) but Theta should have shape: \(theta.shape)")
            //TODO: Error
        }
    }
    
    mutating func setAllMatrices(X: matrix, Y: matrix, R: matrix, Theta: matrix) {
        setX(matrix: X)
        setY(matrix: Y)
        setR(matrix: R)
        setTheta(matrix: Theta)
    }
    
    // MARK: UPDATERS
    
    mutating func updateX(at row: Int, _ columns: Range<Int>, with features: vector) {
        X[row, columns] = features
    }
    
    mutating func updateRatings(at row: Int, _ column: Int, with rating: Double) {
        Y[row - 1, column - 1] = rating
        R[row - 1, column - 1] = 1
    }
    
    mutating func separateTrainingAndTestData() {
        let trainCount = ceil(X.rows.double * 0.7).int
        
        updateTrainingSet(xTrain: X[0..<trainCount, 0..<X.columns], yTrain: Y[0..<trainCount, 0..<Y.columns], rTrain: R[0..<trainCount, 0..<R.columns])
        updateTestSet(xTest: X[trainCount..<X.rows, 0..<X.columns], yTest: Y[trainCount..<Y.rows, 0..<Y.columns], rTest: R[trainCount..<R.rows, 0..<R.columns])
    }
    
    mutating func updateTestSet(xTest: matrix, yTest: matrix, rTest: matrix) {
        self.xTest = xTest
        self.yTest = yTest
        self.rTest = rTest
    }
    
    mutating func updateTrainingSet(xTrain: matrix, yTrain: matrix, rTrain: matrix) {
        self.xTrain = xTrain
        self.yTrain = yTrain
        self.rTrain = rTrain
    }
    
    // MARK: GETTERS
    func getParametersForUser(_ id: Int) -> vector { return theta[id - 1, "all"] }
    
    func getAllMatrices() -> (matrix, matrix, matrix, matrix) {
        return (X, Y, R, theta)
    }
    
    // MARK: PREDICTION
    func predict(movie: Int, user: Int) -> Double {
        //normally feature count would be +1
        let t = theta[user, "all"]
        let x = X[movie, "all"]
        return sum(x * t)
    }
}
    
