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
    
    var newUser = false
    var newUsers = [Int]() // ID
    //    TODO: Remove
    var averageRatings: [Double]?
    
    // Ratings: Y(media, user) = 0.5 - 5
    var Y: matrix
    var YMean: matrix?
    
    // Binary value: R(media, user) = 1 if rated, 0 if not
    var R: matrix
    
    // Binary value for Content Based: X(media, genres) = 1 if has that genre, 0 if not
    var originalX: matrix
    var X: matrix
    
    // Trained Parameters - User
    var originalWeights: matrix
    var weights: matrix
    
    var mediaCount: Int
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
        R = zeros((0,0))
        X = zeros((0,0))
        originalX = zeros((0,0))
        weights = zeros((0,0))
        originalWeights = zeros((0,0))
        userCount = 0
        mediaCount = 0
        featureCount = 0
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
        originalX = X
        originalWeights = weights
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
    
    func normalizeRatings() {
        YMean = zeros_like(Y)
        for row in 0..<Y.rows {
            let mean = sum(Y[row, 0..<Y.columns]) / sum(R[row, 0..<Y.columns])
            for col in 0..<Y.columns {
                YMean![row, col] = mean * R[row, col]
            }
        }
        Y = Y - YMean!
    }
    
    func resetMatrices() {
        self.weights = originalWeights
        self.X = originalX
    }
    
    func addUser(averages: [Double]) {
        newUser = true
        newUsers.append(userCount)
        averageRatings = averages
        // Y,R(movie, user)
        // X
        self.userCount += 1
        var newR = zeros((mediaCount, userCount))
        newR[0..<mediaCount, 0..<userCount-1] = R
        R = newR
        
        var newY = zeros((mediaCount, userCount))
        newY[0..<mediaCount, 0..<userCount-1] = Y
        Y = newY
        
        if algorithmType == .ContentBased {
            var newWeights = rand((userCount, featureCount+1))
            newWeights[0..<userCount-1, 0..<featureCount+1] = weights
            weights = newWeights
            
        } else {
            var newWeights = rand((userCount, featureCount))
            newWeights[0..<userCount-1, 0..<featureCount] = weights
            weights = newWeights
        }
        originalWeights = weights
    }
    
    // MARK: UPDATERS
    func updateX(at row: Int, _ columns: Range<Int>, with features: vector) {
        X[row, columns] = features
    }
    
    func updateRatings(at row: Int, _ column: Int, with rating: Double) {
        Y[row, column] = rating
        if rating > 0 {
            R[row, column] = 1
//            print(row, column - 1)
        }
    }
    
    // MARK: GETTERS
    func getParametersForUser(_ id: Int) -> vector { return weights[id - 1, "all"] }
    
    func getAllMatrices() -> (matrix, matrix, matrix, matrix) {
        return (X, Y, R, weights)
    }
    
    // MARK: PREDICTION
    func predict(media: Int, user: Int) -> Double {
        // normally feature count would be +1
//        guard let mean = YMean else { return 0.0 }
        let w = weights[user, "all"]
        let x = X[media, "all"]
        var prediction = sum(x * w)
        
//        prediction += mean[media, user]
//        print(mean[media, user])
        
        return prediction
    }
}
    
