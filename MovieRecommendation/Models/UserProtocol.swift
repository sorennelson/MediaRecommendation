//
//  UserProtocol.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 1/10/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

protocol UserProtocol: Hashable {
    var id: Int { get }
    var ratings: [Double] { get set }
    
    // Number of movies rated by user
    var mj: Int { get set }
    
    mutating func addRating(_ rating: Double, for media: Int)
}

extension UserProtocol {
    mutating func addRating(_ rating: Double, for media: Int) {
        mj += 1
        ratings[media - 1] = rating;
    }
}

// MARK: Hashable Protocol
extension UserProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return id.hashValue
    }
}
