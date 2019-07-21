//
//  Content.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 2/16/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

enum Content {
    case Recommendations
    case Ratings
    case Categories
}

enum MediaType {
    case Movies
    case Books
}

protocol UpdateContent {
    func selectedCategory(_ categoryRow: Int, category: Category)
}
