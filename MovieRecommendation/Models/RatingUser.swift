//
//  RatingUser.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/10/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class RatingUser: NSObject, UserProtocol {
    
    var id: Int
    var ratings: [Double] // ratings by user, index is mID
    var numMediaRatings: Int // Number of medium rated by user
    
    init(id: Int, numMedia: Int) {
        self.id = id
        numMediaRatings = 0
        ratings = Array(repeating: 0, count: numMedia)
    }
    
//    init(id: Int, ratings: [Double], numMediaRatings: Int) {
//        self.id = id
//        self.ratings = ratings
//        self.numMediaRatings = numMediaRatings
//    }
    
    override public var description: String {
        return String("ID: \(id) \nratings: \(ratings)")
    }
    
    func getRating(for id: Int) -> Double {
        return ratings[id]
    }
}

class User: NSObject {
    
    var bookRatingUser: RatingUser?
    var booksRated: [Int: Double]  // [ID: Rating]
    var movieRatingUser: RatingUser?
    var moviesRated: [Int: Double]  // [ID: Rating]
    
    init(movieUser: RatingUser, moviesRated: [Int: Double],  bookUser: RatingUser, booksRated: [Int: Double]) {
        self.movieRatingUser = movieUser
        self.moviesRated = moviesRated
        
        self.bookRatingUser = bookUser
        self.booksRated = booksRated
    }

//    init(ubid:Int, numBooks: Int, umid:Int, numMovies: Int) {
//        self.bookRatingUser = RatingUser(id: ubid, numMedia: numBooks)
//        self.booksRated = [:]
//        self.movieRatingUser = RatingUser(id: umid, numMedia: numMovies)
//        self.moviesRated = [:]
//    }
    
    func rate(_ type: MediaType, with id: Int, rating: Double) {
        switch type {
        case .Books:
            if bookRatingUser!.ratings[id] > 0.0 {
                bookRatingUser?.numMediaRatings += 1
            }
            bookRatingUser?.ratings[id] = rating
            booksRated[id] = rating
        
        case .Movies:
            if movieRatingUser!.ratings[id] > 0.0 {
                movieRatingUser?.numMediaRatings += 1
            }
            movieRatingUser?.ratings[id] = rating
            moviesRated[id] = rating
        }
    }
    
}
