//
//  Media.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 1/10/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

protocol MediaProtocol: Hashable {
    var yID: Int { get }
    var title: String { get }
    var genres: [String] { get }
    var features: vector { get set }
    var ratings: [Double] { get set }
    
    mutating func addRating(_ rating: Double, for user: Int)
}


extension MediaProtocol {
    mutating func addRating(_ rating: Double, for user: Int) {
        ratings[user - 1] = rating;
    }
}


// MARK: Hashable Protocol
extension MediaProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.yID == rhs.yID
    }
    
    var hashValue: Int {
        return yID.hashValue
    }
}
