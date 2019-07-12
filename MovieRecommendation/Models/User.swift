//
//  User.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/10/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class User: Codable {
    
    static var current:User?
    
    var username: String
    var id: String
    
//    var bookRatingIDs: [Int]
//    var bookRatings: [Double]
//    var movieRatingIDs: [Int]
//    var movieRatings: [Double]
    
    
    //    init() {
    //
    //    }
    
    func rate(_ type: MediaType, with id: Int, rating: Double) {
        //        switch type {
        //        case .Books:
        //            if bookRatingUser!.ratings[id] > 0.0 {
        //                bookRatingUser?.numMediaRatings += 1
        //            }
        //            bookRatingUser?.ratings[id] = rating
        //            booksRated[id] = rating
        //
        //        case .Movies:
        //            if movieRatingUser!.ratings[id] > 0.0 {
        //                movieRatingUser?.numMediaRatings += 1
        //            }
        //            movieRatingUser?.ratings[id] = rating
        //            moviesRated[id] = rating
        //        }
    }
}
