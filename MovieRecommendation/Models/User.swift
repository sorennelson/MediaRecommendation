//
//  User.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/10/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class User: Hashable {
    
    var id: Int
    var ratings: [Double]
    var theta: vector
    // Number of movies rated by user
    var mj: Int
    
    init(id: Int, theta: vector) {
        self.id = id
        mj = 0
        ratings = Array(repeating: 0, count: 164979)
        self.theta = theta
    }
    
    public var description: String {
        return String("ID: \(id) \nratings: \(ratings)")
    }
    
    func addRating(_ rating: Double, for movie: Int) {
        mj += 1
        ratings[movie - 1] = rating;
    }
    
    // MARK: Hashable Protocol
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return id.hashValue
    }
}
