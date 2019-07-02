//
//  Book.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 3/21/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

class Book: Media {
    
    var author: String
    var smallImageURL: URL?
    
    init(id: Int, title: String, author: String, year: Int, genres: [String], avgRating: Double,
         imageURL: URL?, smallImageURL: URL?) {
        self.author = author
        self.smallImageURL = smallImageURL
        
        super.init(id: id, title: title, genres: genres, year: year, avgRating: avgRating, imageURL: imageURL)
    }
    
    private enum BookKeys: String, CodingKey {
        case author
        case smallImageURL = "small_image_url"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BookKeys.self)
        author = try container.decode(String.self, forKey: .author)
        smallImageURL = try container.decode(URL?.self, forKey: .smallImageURL)
        
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }
}
