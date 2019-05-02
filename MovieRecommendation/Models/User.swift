//
//  User.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/10/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class User: NSObject, UserProtocol {
    
    var id: Int
    var ratings: [Double] // ratings by user, index is mID
    var mj: Int // Number of medium rated by user
    
    init(id: Int, numMedia: Int) {
        self.id = id
        mj = 0
        ratings = Array(repeating: 0, count: numMedia)
    }
    
    override public var description: String {
        return String("ID: \(id) \nratings: \(ratings)")
    }
    
    func getRating() -> Double {
        // TODO :  UserProtocol
        return 0.0
    }
    
}
