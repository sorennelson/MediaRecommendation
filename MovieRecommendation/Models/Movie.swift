//
//  Movie.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/10/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class Movie: Media {
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

struct MovieRating: Codable, Equatable {
    let movie: Movie
    var rating: Float
    
    static func == (lhs: MovieRating, rhs: MovieRating) -> Bool {
        return lhs.movie == rhs.movie
    }
}


//if let string = imageString {
//    if !string.isEmpty {
//        self.imageURL = "https://image.tmdb.org/t/p/w342" + string
//    }
//}
