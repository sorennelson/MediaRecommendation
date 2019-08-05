//
//  Movie.swift
//  MediaRecommendation
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

class MovieSeries: Codable {
    let name: String
    let movies: [Movie]
    var showMedia: Movie
    
    enum MovieSeriesKeys: String, CodingKey {
        case name
        case movies
        case showMedia = "most_viewed"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieSeriesKeys.self)
        name = try container.decode(String.self, forKey: .name)
        movies = try container.decode([Movie].self, forKey: .movies)
        showMedia = try container.decode(Movie.self, forKey: .showMedia)
    }
}
