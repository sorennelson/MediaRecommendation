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
    
    func getCost() -> Double
    func getGrad() -> matrix
    func getParametersForUser(_ id: Int) -> vector
    
    func setMatrices(X: matrix, Y: matrix, R: matrix, Theta: matrix)
    
    func updateX(at row: Int, _ columns: Range<Int>, with features: vector)
    func updateRatings(at row: Int, _ column: Int, with rating: Double)
    
    func createEmptyMatrices(movieCount: Int, userCount: Int, featureCount: Int)
    func runGradientDescent(iterations:Int, alpha: Double)
    func takeStep(lambda: Double) -> (Double, matrix)
}

class RecommenderModel {
    
    // Ratings: Y(movie, user) = 0.5 - 5
    var Y: matrix
    
    // Binary value: R(movie, user) = 1 if rated, 0 if not
    var R: matrix
    
    // Binary value: X(movie, user) = 1 if has that genre, 0 if not
    var X: matrix
    
    // Binary value: X(movie, user) = 1 if has that genre, 0 if not
    var theta: matrix
    
    var movieCount: Int
    var featureCount: Int
    var userCount: Int
    
    // TODO: Set to multiple values. Look through Large Scale Machine Learning
    var alpha: Int
    // var lambda: Int
    var J: Double
    var grad: matrix
    
    // var unrolledTheta: matrix = matrix(columns: 1, rows: 671*19)
    // var unrolledX: matrix = matrix(columns: 1, rows: 164979*19)
    
    /* ----------------------------------------------------------------------------------------------------
     Movie_Data:
     nm: # of movies = 164979
     nu: # of users = 671
     n : # of features = 18 - 0 based
     ---------------------------------------------------------------------------------------------------- */
    
    init() {
        Y = zeros((0,0))
        R = zeros((0,0))
        X = zeros((0,0))
        theta = zeros((0,0))
        userCount = 0
        movieCount = 0
        featureCount = 0
        alpha = 0
       // lambda = 0
        J = 0
        grad = zeros((0, 0))
    }

    init(movieCount: Int, userCount: Int, featureCount: Int) {
        Y = zeros((movieCount, userCount))
        R = zeros((movieCount, userCount))
        X = zeros((movieCount, featureCount + 1))
        theta = rand((userCount, featureCount + 1))
        self.movieCount = movieCount
        self.userCount = userCount
        self.featureCount = featureCount
        alpha = 0
        // lambda = 0
        J = 0
        grad = zeros((userCount, featureCount + 1))
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
}
    
