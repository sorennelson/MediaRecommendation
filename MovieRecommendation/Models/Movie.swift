//
//  Movie.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/10/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class Movie: Media {
    
    override init(id: Int, title: String, genres: [String], year: Int, avgRating: Double, imageURL: URL?) {
        super.init(id: id, title: title, genres: genres, year: year, avgRating: avgRating, imageURL: imageURL)
        //        if let string = imageString {
        //            if !string.isEmpty {
        //                self.imageURL = "https://image.tmdb.org/t/p/w342" + string
        //            }
        //        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }
}

class Movies: Codable {
    let results: [Movie]
}
    
//    private func setFeatures() {
//        for genre in genres {
//            switch genre {
//            case "Action":
//                features[0] = 1
//            case "Adventure":
//                features[1] = 1
//            case "Animation":
//                features[2] = 1
//            case "Children's":
//                features[3] = 1
//            case "Comedy":
//                features[4] = 1
//            case "Crime":
//                features[5] = 1
//            case "Documentary":
//                features[6] = 1
//            case "Drama":
//                features[7] = 1
//            case "Fantasy":
//                features[8] = 1
//            case "Film-Noir":
//                features[9] = 1
//            case "Horror":
//                features[10] = 1
//            case "Musical":
//                features[11] = 1
//            case "Mystery":
//                features[12] = 1
//            case "Romance":
//                features[13] = 1
//            case "Sci-Fi":
//                features[14] = 1
//            case "Thriller":
//                features[15] = 1
//            case "War":
//                features[16] = 1
//            case "Western":
//                features[17] = 1
//            default:
//                // no genres listed
//                return
//            }
//        }
//    }


