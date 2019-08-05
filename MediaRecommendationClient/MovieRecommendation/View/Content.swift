//
//  Content.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 2/16/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

enum Content {
    case Recommendations
    case MostRecent
    case MostViewed
    case Ratings
    case Categories
    case Series
}

enum MediaType {
    case Movies
    case Books
}

protocol UpdateContent {
    func selectedCategory(_ categoryRow: Int, category: Genre)
    func changeContent(to content: Content)
}
