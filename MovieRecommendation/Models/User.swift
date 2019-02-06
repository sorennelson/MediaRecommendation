//
//  User.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/10/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class User: UserProtocol {
    
    var id: Int
    var ratings: [Double]
    
    // Number of movies rated by user
    var mj: Int
    
    init(id: Int) {
        self.id = id
        mj = 0
        ratings = Array(repeating: 0, count: 9125)
    }
    
    public var description: String {
        return String("ID: \(id) \nratings: \(ratings)")
    }
    
    func getRating() -> Double {
        // TODO :  UserProtocol
        return 0.0
    }
    
}
