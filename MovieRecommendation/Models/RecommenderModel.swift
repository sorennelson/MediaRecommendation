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

    func setX(matrix: matrix)
    func setY(matrix: matrix)
    func setR(matrix: matrix)
    func setTheta(matrix: matrix)
    
    func updateX(at row: Int, _ columns: Range<Int>, with features: vector)
    func updateRatings(at row: Int, _ column: Int, with rating: Double)
    
    func runGradientDescent(movieCount: Int, userCount: Int, featureCount: Int)
    func takeStep()
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
    
    // TODO: Set to multiple values. Look through Large Scale Machine Learning
    var alpha: Int
    var lambda: Int
    var J: Double
    var thetaGrad: matrix
    
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
        alpha = 0
        lambda = 0
        J = 0
        thetaGrad = zeros((0, 0))
    }

    init(movieCount: Int, userCount: Int, featureCount: Int) {
        Y = zeros((movieCount, userCount))
        R = zeros((movieCount, userCount))
        X = zeros((movieCount, featureCount + 1))
        theta = rand((movieCount, featureCount + 1))
        alpha = 0
        lambda = 0
        J = 0
        thetaGrad = zeros((userCount, featureCount + 1))
    }
}
    
