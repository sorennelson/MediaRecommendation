//
//  ParseController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 7/10/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation

class ParseController {
    
    static let sharedInstance = ParseController()
        
    func importFileAt(_ filePath: String, ofType fileType: String) -> String? {
        guard let path = Bundle.main.path(forResource: filePath, ofType: fileType) else {
            print("Incorrect path to file")
            return nil
        }
        do {
            return try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            
        } catch {
            print("Unable to encode file")
            return nil
        }
    }
    
    func importAndParseMovies() {
        MovieParser.sharedInstance.importAndParseMovies()
    }
    
    func importAndParseBooks() {
        BookParser.sharedInstance.importAndParseBooks()
    }
    
    func importToContentBasedMLModel<T: Media>(media: [Int:T], featureCount: Int) -> RecommenderModel {
        let temp = changeDictionaryToArray(media: media)
        return ImportController.sharedInstance.addMediaAndRatings(temp, for: ObjectController.sharedInstance.movieUsers, featureCount: featureCount)
    }
    
    func importToCollaborativeFilteringMLModel<T: Media>(media: [Int:T], featureCount: Int) -> RecommenderModel {
        let temp = changeDictionaryToArray(media: media)
        return ImportController.sharedInstance.addRatings(temp, for: ObjectController.sharedInstance.movieUsers, featureCount: featureCount)
    }
    
    private func changeDictionaryToArray<T: Media>(media: [Int:T]) -> [T] {
        var keys = Array(media.keys)
        keys = keys.sorted()
        var array = [T]()
        
        for key in keys {
            if let m = media[key] {
                array.append(m)
            }
        }
        return array
    }
    
//    private func changeDictionaryToArray<T: Media, U: UserProtocol>(_ media: [T], for users: [U]) -> [T] {
//        var keys = Array(MovieParser.sharedInstance.movies.keys)
//        keys = keys.sorted()
//        var temp = [T]()
//
//        for key in keys {
//            if let m = media[key] {
//                temp.append(m)
//            }
//        }
//        return temp
//    }
    
}
