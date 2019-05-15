//
//  Movie.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/10/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class Movie: Media {
    
//    var tmdbLink: URL?
    
    init(yid: Int, title: String, imageString: String?, genres: [String]) {
        super.init(id: yid, title: title, genres: genres, features: zeros(19), ratings: Array(repeating: 0, count: 671) )
        if let string = imageString {
            if !string.isEmpty {
                self.imageURL = "https://image.tmdb.org/t/p/w342" + string
            }
        }
        setFeatures()
    }
    
    override public var description: String {
        return String("ID: \(yID) \nTitle: \(title) \ngenre: \(genres) \nratings: \(ratings)")
    }
    
    //        https://api.themoviedb.org/3/movie/862?api_key=60d78c7cfee3c407c714903efd4c3359&language=en-US
    //        tmdbLink = URL(string: "https://api.themoviedb.org/3/movie/" + String(tmdbID) + "?api_key=60d78c7cfee3c407c714903efd4c3359&language=en-US")
    
    //        imageURL =
    //        "https://image.tmdb.org/t/p/w500/6ksm1sjKMFLbO7UY2i6G1ju9SML.jpg"
    
    private func setFeatures() {
        for genre in genres {
            switch genre {
            case "Action":
                features[0] = 1
            case "Adventure":
                features[1] = 1
            case "Animation":
                features[2] = 1
            case "Children's":
                features[3] = 1
            case "Comedy":
                features[4] = 1
            case "Crime":
                features[5] = 1
            case "Documentary":
                features[6] = 1
            case "Drama":
                features[7] = 1
            case "Fantasy":
                features[8] = 1
            case "Film-Noir":
                features[9] = 1
            case "Horror":
                features[10] = 1
            case "Musical":
                features[11] = 1
            case "Mystery":
                features[12] = 1
            case "Romance":
                features[13] = 1
            case "Sci-Fi":
                features[14] = 1
            case "Thriller":
                features[15] = 1
            case "War":
                features[16] = 1
            case "Western":
                features[17] = 1
            default:
                // no genres listed
                return
            }
        }
    }
}

