//
//  Media.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 4/18/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

class Media: Hashable, Codable {
    
    var id: Int
    var title: String
    var genres: [String]
    var year: Int
    var avgRating: Double
    
    var imageURL: String?
    var imageData: Data?
    
    init(id: Int, title: String, genres: [String], year: Int, avgRating: Double, imageURL:String?) {
        self.id = id
        self.title = title
        self.genres = genres
        self.year = year
        self.avgRating = avgRating
        self.imageURL = imageURL
    }
    
    func getImageData(completion:@escaping (Data?) -> ()) {
        if let imageData = imageData {
            completion(imageData)
            
        } else {
            if let imageString = imageURL,
                let url = URL(string: imageString) {
                
                DispatchQueue.global(qos: .background).async {
                    let data = try? Data(contentsOf: url)
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
