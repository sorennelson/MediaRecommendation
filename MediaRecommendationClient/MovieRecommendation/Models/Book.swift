//
//  Book.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 3/21/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

class Book: Media {
    
    var author: String
    var description: String?
    var numPages: Int
    var publisher: String?
    var smallImageURL: URL?
    
    init(id: Int, title: String, author: String, description: String?, numPages: Int?,
         publisher: String?, year: Int, genres: [String], avgRating: Double,
         imageURL: URL?, smallImageURL: URL?) {
        
        self.author = author
        self.description = description
        
        if let numPages = numPages {
            self.numPages = numPages
        } else {
            self.numPages = 0
        }
        self.publisher = publisher
        self.smallImageURL = smallImageURL
        
        super.init(id: id, title: title, genres: genres, year: year, avgRating: avgRating, imageURL: imageURL)
    }
    
    private enum BookKeys: String, CodingKey {
        case author
        case smallImageURL = "small_image_url"
        case description
        case numPages = "num_pages"
        case publisher
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BookKeys.self)
        author = try container.decode(String.self, forKey: .author)
        smallImageURL = try container.decode(URL?.self, forKey: .smallImageURL)
        
        description = try container.decode(String?.self, forKey: .description)
        numPages = try container.decode(Int.self, forKey: .numPages)
        publisher = try container.decode(String?.self, forKey: .publisher)
        
        try super.init(from: decoder)
    }
}

struct BookRating: Codable, Equatable {
    let book: Book
    var rating: Float
    
    static func == (lhs: BookRating, rhs: BookRating) -> Bool {
        return lhs.book == rhs.book
    }
}

class BookSeries: Codable {
    let name: String
    let books: [Book]
    var showMedia: Book
    
    enum BookSeriesKeys: String, CodingKey {
        case name
        case books
        case showMedia = "most_viewed"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BookSeriesKeys.self)
        name = try container.decode(String.self, forKey: .name)
        books = try container.decode([Book].self, forKey: .books)
        showMedia = try container.decode(Book.self, forKey: .showMedia)
    }
}


