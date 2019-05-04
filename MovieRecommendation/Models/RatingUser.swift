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
    
    init(id: Int, ratings: [Double], numMediaRatings: Int) {
        self.id = id
        self.ratings = ratings
        self.numMediaRatings = numMediaRatings
    }
    
    override public var description: String {
        return String("ID: \(id) \nratings: \(ratings)")
    }
    
    func getRating(for id: Int) -> Double {
        return ratings[id]
    }
}


class User: NSObject {
    
    var firID: String
    var bookRatingUser: RatingUser?
    var movieRatingUser: RatingUser?

    init(firID: String, ubid:Int, numBooks: Int, umid:Int, numMovies: Int) {
        self.firID = firID
        self.bookRatingUser = RatingUser(id: ubid, numMedia: numBooks)
        self.movieRatingUser = RatingUser(id: umid, numMedia: numMovies)
    }
    
    func rate(_ type: MediaType, with id: Int, rating: Double) {
        switch type {
        case .Books:
            if bookRatingUser!.ratings[id] > 0.0 {
               bookRatingUser?.numMediaRatings += 1
            }
            bookRatingUser?.ratings[id] = rating
        
        case .Movies:
            if movieRatingUser!.ratings[id] > 0.0 {
                movieRatingUser?.numMediaRatings += 1
            }
            movieRatingUser?.ratings[id] = rating
        }
    }
    
//    MARK: FIREBASE
    private let BIDKEY = "ubid"
    private let BOOKRATINGSKEY = "book_ratings"
    private let BOOKNUMRATINGSKEY = "num_book_ratings"
    private let MIDKEY = "umid"
    private let MOVIERATINGSKEY = "movie_ratings"
    private let MOVIENUMRATINGSKEY = "num_movie_ratings"
    
    init(firID: String, dict: [String: Any]) {
        self.firID = firID
        guard let bID = dict[BIDKEY] as? NSNumber,
            let bookRatings = dict[BOOKRATINGSKEY] as? [NSNumber],
            let numBookRatings = dict[BOOKNUMRATINGSKEY] as? NSNumber else {
                return
        }
        self.bookRatingUser = RatingUser(id: bID as! Int, ratings: bookRatings as! [Double], numMediaRatings: numBookRatings as! Int)
        
        guard let mID = dict[MIDKEY] as? NSNumber,
            let movieRatings = dict[MOVIERATINGSKEY] as? [NSNumber],
            let numMovieRatings = dict[MOVIENUMRATINGSKEY] as? NSNumber else {
                return
        }
        
        self.movieRatingUser = RatingUser(id: mID as! Int, ratings: movieRatings as! [Double], numMediaRatings: numMovieRatings as! Int)
    }
    
    func toAnyObject() -> Any {
        var userDict = [String: Any]()
        if let bookRatingUser = bookRatingUser {
            userDict[BIDKEY] = bookRatingUser.id as NSNumber
            userDict[BOOKRATINGSKEY] = bookRatingUser.ratings as [NSNumber]
            userDict[BOOKNUMRATINGSKEY] = bookRatingUser.numMediaRatings as NSNumber
        }
        if let movieRatingUser = movieRatingUser {
            userDict[MIDKEY] = movieRatingUser.id as NSNumber
            userDict[MOVIERATINGSKEY] = movieRatingUser.ratings as [NSNumber]
            userDict[MOVIENUMRATINGSKEY] = movieRatingUser.numMediaRatings as NSNumber
        }
        
        return [firID: userDict]
    }
    
//    init(firID: Int, bookRatings: [Double], movieRatings: [Double]) {
//        self.firID = firID
//
//    }
    
    
}
