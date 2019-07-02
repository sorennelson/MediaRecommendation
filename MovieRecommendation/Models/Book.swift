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
    
    var smallImageURL: String?
    
    init(id: Int, goodreadsID: Int, title: String, author: String, year: Int, genres: [String], avgRating: Double,
         imageURL: String?, smallImageURL: String?) {
        self.goodreadsID = goodreadsID
        self.author = author
        self.smallImageURL = smallImageURL
        
        super.init(id: id, title: title, genres: genres, year: year, avgRating: avgRating, imageURL: imageURL)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
