//
//  Movie.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/10/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class Movie: Hashable {

    var yID: Int;
    var title: String;
    var genres: [String]
    var features: vector
    var ratings: [Double]
    
    // TODO: Add avg rating calculation
//    var averageRating: Double?

    
    init(id: Int, title: String, genres: [String]) {
        self.yID = id;
        self.title = title;
        self.genres = genres;
        self.ratings = Array(repeating: 0, count: 671)
        self.features = zeros(19)
        setFeatures()
    }
    
    public var description: String {
        return String("ID: \(yID) \nTitle: \(title) \ngenre: \(genres) \nratings: \(ratings)")
    }
    
    func addRating(_ rating: Double, for user: Int) {
        self.ratings[user - 1] = rating;
    }
    
    func setFeatures() {
        self.features[0] = 1
        for genre in genres {
            switch genre {
            case "Action":
                features[1] = 1
            case "Adventure":
                features[2] = 1
            case "Animation":
                features[3] = 1
            case "Children's":
                features[4] = 1
            case "Comedy":
                features[5] = 1
            case "Crime":
                features[6] = 1
            case "Documentary":
                features[7] = 1
            case "Drama":
                features[8] = 1
            case "Fantasy":
                features[9] = 1
            case "Film-Noir":
                features[10] = 1
            case "Horror":
                features[11] = 1
            case "Musical":
                features[12] = 1
            case "Mystery":
                features[13] = 1
            case "Romance":
                features[14] = 1
            case "Sci-Fi":
                features[15] = 1
            case "Thriller":
                features[16] = 1
            case "War":
                features[17] = 1
            case "Western":
                features[18] = 1
            default:
                // no genres listed
                return
            }
        }
    }
    
    // MARK: Hashable Protocol
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.yID == rhs.yID
    }

    var hashValue: Int {
        return yID.hashValue
    }

}

