//
//  ObjectController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 4/20/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

class ObjectController {
    
    static var sharedInstance = ObjectController()
    static var currentMediaType = MediaType.Movies
    
    var movies: [Int: Movie] = Dictionary.init() // YID: Movie
    var movieLinks = [Int: String]() // YID: Link
    var movieUsers: [User] = []
    var genreMovies: [String: [Int]] = [:] // [genre: [movieIDs]]
    
    var books: [Int: Book] = [:]
    var allBookGenres: [String] = []
//    var bookGenres: [Int: [String]] = [:] // [bookID: [genres]]
    var genreBooks: [String: [Int]] = [:] // [genre: [bookIDs]]
    var bookUsers: [User] = []
    
    func getAllMedia() -> [Int: Media] {
        switch ObjectController.currentMediaType {
        case .Books:
            return books
        case .Movies:
            return movies
        }
    }
    
    func getAllMediaCount() -> Int {
        switch ObjectController.currentMediaType {
        case .Books:
            return books.count
        case .Movies:
            return movies.count
        }
    }
    
    func getAllMedia(for index: Int) -> Media? {
        switch ObjectController.currentMediaType {
        case .Books:
            return books[index]
        case .Movies:
            return movies[index]
        }
    }
    
}
