//
//  User.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 7/10/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class User: Codable {
    
    static var current:User?
    var id: Int
    var username: String
    
    var bookRatings: [BookRating]?
    var movieRatings: [MovieRating]?
    
    private enum UserKeys: String, CodingKey {
        case id
        case username
    }
}


