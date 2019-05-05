//
//  ImportController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 1/10/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

class ImportController {
    
    static let sharedInstance = ImportController()
    
    func addMediaAndRatings<T: Media, U: UserProtocol>(_ media: [T], for users: [U], featureCount: Int) -> RecommenderModel {
        var RM = RecommenderModel(mediaCount: media.count, userCount: users.count, featureCount: featureCount, type: RMType.ContentBased)
        
        for m in media {
            if m.features.count < featureCount {
//                print("IMPORT TO ML: MEDIA ERROR")
                // throw error
            }
            RM.updateX(at: m.yID - 1, 1..<featureCount+1, with: m.features)
        }
        
        print(media.count)
        for u in users {
            if u.ratings.count < media.count {
//                print(u.ratings.count)
//                print("IMPORT TO ML: USER ERROR")
                // throw error
            }
            for mID in 0..<u.ratings.count {
                RM.updateRatings(at: mID, u.id, with: u.ratings[mID])
            }
        }
        return RM
    }
    
    
    func addRatings<T: Media, U: UserProtocol>(_ media: [T], for users: [U], featureCount: Int) -> RecommenderModel {
        var RM = RecommenderModel(mediaCount: media.count, userCount: users.count, featureCount: featureCount, type: RMType.CollaborativeFiltering)

        for u in users {
            if u.ratings.count < media.count {
                print("ERROR")
                // throw error
            }
            for mID in 0..<u.ratings.count {
                RM.updateRatings(at: mID, u.id, with: u.ratings[mID])
            }
        }
        return RM
    }
    
}
