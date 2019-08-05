//
//  Media.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 4/18/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation


struct Genre: Codable {
    let name: String
    let count: Int
}

class Media: Equatable, Codable {
    
    var id: Int
    var title: String
    var genres: [String]
    var year: Int
    var avgRating: Double
    var numViewed: Int
    
    var imageURL: URL?
    var imageData: Data?
    
    init(id: Int, title: String, genres: [String], year: Int, avgRating: Double, imageURL:URL?) {
        self.id = id
        self.title = title
        self.genres = genres
        self.year = year
        self.avgRating = avgRating
        self.numViewed = 1
        self.imageURL = imageURL
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case genres
        case year
        case avgRating = "average_rating"
        case numViewed = "num_watched"
        case imageURL = "image_url"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        genres = try container.decode([String].self, forKey: .genres)
        year = try container.decode(Int.self, forKey: .year)
        let avgFloat = try container.decode(Float.self, forKey: .avgRating)
        avgRating = Double(avgFloat)
        numViewed = try container.decode(Int.self, forKey: .numViewed)
        imageURL = try container.decode(URL?.self, forKey: .imageURL)
    }
    
    func getImageData(completion:@escaping (Data?) -> ()) {
        completion(nil)
        if let imageData = imageData {
            completion(imageData)

        } else {
            if let imageURL = imageURL {

                DispatchQueue.global(qos: .background).async {
                    let data = try? Data(contentsOf: imageURL)
                    self.imageData = data
                    completion(data)
                }

            } else { completion(nil) }
        }
    }
    
    //    MARK: Hashable
    static func == (lhs: Media, rhs: Media) -> Bool {
        return lhs.id == rhs.id
    }
}
