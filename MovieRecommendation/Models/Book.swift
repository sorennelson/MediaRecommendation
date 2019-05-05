//
//  Book.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 3/21/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

class Book: Media {
    
    var goodreadsID: Int
    var author: String
    var year: String?
    
    init(id: Int, goodreadsID: Int, title: String, author: String, year: String?, genres: [String], allBookGenres:[String], avgRating: Double, imageString: String) {
        self.goodreadsID = goodreadsID
        self.author = author
        self.year = year
        
        super.init(id: id, title: title, genres: genres, features: zeros(994 + 1), ratings: Array(repeating: 0, count: 53425))
        self.avgRating = avgRating
        self.imageURL = imageString
        setFeatures(allBookGenres: allBookGenres)
    }
    
    private func setFeatures(allBookGenres: [String]) {
        for genre in genres {
            if let i = allBookGenres.firstIndex(of: genre) {
                self.features[i] = 1
            } else {
                print("Couldn't find Genre in Features")
            }
        }
    }
}

// MARK: Book Genre Work
extension Book {
    static let genreExceptions = [
        "to-read", "currently-reading", "owned", "default", "favorites", "books-i-own",
        "ebook", "kindle", "library", "audiobook", "owned-books", "audiobooks", "my-books",
        "ebooks", "to-buy", "english", "calibre", "books", "british", "audio", "my-library",
        "favourites", "re-read", "general", "e-books"
    ]
    
    static func isValid(genre: String) -> Bool {
        return !genreExceptions.contains(genre)
    }
}
