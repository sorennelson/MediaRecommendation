//
//  GradientDescent.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/15/18.
//  Copyright © 2018 SORN. All rights reserved.
//
// https://stsievert.com/swix/matrix.html#module-matrix ~ Swix

import Foundation

protocol RMDelegate {
    
    func getParametersForUser(_ id: Int) -> vector
    func getMatrices() -> (matrix, matrix, matrix, matrix)
    
    func setMatrices(X: matrix, Y: matrix, R: matrix, Theta: matrix)
    func createEmptyMatrices(movieCount: Int, userCount: Int, featureCount: Int)
    
    func updateX(at row: Int, _ columns: Range<Int>, with features: vector)
    func updateRatings(at row: Int, _ column: Int, with rating: Double)
    func updateTestSet(xTest: matrix, yTest: matrix, rTest: matrix)
    func updateTrainingSet(xTrain: matrix, yTrain: matrix, rTrain: matrix)
    
    func runGradientDescent(lambda: Double, iterations: Int, alpha: Double) -> matrix
    func takeStep(lambda: Double) -> (Double, matrix)
    func computeTrainSetError(theta: matrix) -> Double
    func computeTestSetError(theta: matrix) -> Double
    func predict(movie: Int, user: Int) -> Double
}

class RecommenderModel {
    
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
    
    func setX(matrix: matrix) {
        if (matrix.shape == (movieCount, featureCount)) {
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
    
    func setTheta(matrix: matrix) {
        if (matrix.shape == (userCount, featureCount)) {
            theta = matrix
        } else {
            print("Matrix has shape: \(matrix.shape) but Theta should have shape: \(theta.shape)")
            //TODO: Error
        }
    }
    
    func predict(movie: Int, user: Int) -> Double {
        //normally feature count would be +1
        let t = theta[user, "all"]
        let x = X[movie, "all"]
        return sum(x * t)
    }
}
    
