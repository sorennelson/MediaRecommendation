//
//  ObjectController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 4/20/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Alamofire

class ObjectController {
    
    static var sharedInstance = ObjectController()
    static var currentMediaType = MediaType.Movies
    
    var allMovies: [Movie] = []
    var recommendedMovies: [Movie] = []
    var allBooks: [Book] = []
    var recommendedBooks: [Book] = []
    
    // Not currently using
    var addedRatings = false
    
    var genreMovies: [String: [Int]] = [:] // [genre: [movieIDs]]
    var allBookGenres: [String] = []
    var bookRatings: [Media: Double]?
    
    var selectedMedia: Media?
    var selectedMediaPrediction: Double?
    
    func noRecommendations() -> Bool {
        return ObjectController.currentMediaType == .Books ? recommendedBooks.count > 0 : recommendedMovies.count > 0
    }
    
    func getMedia(for indices: Range<Int>) -> [Media] {
        if let _ = User.current {
            switch ObjectController.currentMediaType {
            case .Books:
                return getMedia(for: indices, in: recommendedBooks)
                
            case .Movies:
                return getMedia(for: indices, in: recommendedMovies)
            }
        } else {
            switch ObjectController.currentMediaType {
            case .Books:
                return getMedia(for: indices, in: allBooks)
                
            case .Movies:
                return getMedia(for: indices, in: allMovies)
            }
        }
    }
    
    private func getMedia(for indices: Range<Int>, in array: [Media]) -> [Media] {
        var media = [Media]()
        for i in indices {
            if array.indices.contains(i) {
                media.append(array[i])
            }
        }
        return media
    }
    
    func getMediaCount() -> Int {
        if let _ = User.current {
            return ObjectController.currentMediaType == .Books ? recommendedBooks.count : recommendedMovies.count
        } else {
            return ObjectController.currentMediaType == .Books ? allBooks.count : allMovies.count
        }
    }
    
    func getAllMediaCount() -> Int {
        return ObjectController.currentMediaType == .Books ? allBooks.count : allMovies.count
    }
    
    func getAllMedia(for index: Int) -> Media? {

        return nil
    }
    
    func getAllMedia(for indices: Range<Int>) -> [Media]? {

        return nil
    }
    
    func addRating(_ rating: Double, for media: Media) -> Bool {
       
        return true
    }
    
    func getAllCategories() -> [String]? {
        
        return nil
    }
    
    func getMediaForCategory(genreName: String) -> [Media]? {
        
        return nil
    }
    
    func getCategoryCount(genreName: String) -> Int {
        
        return 0
    }
    
    func getMediaForCategory(genreName: String, at indices: Range<Int>) -> [Media]? {
        
        return nil
    }
    
    func doneAddingRatings() {
        
    }
    
    func getPrediction(for media: Media) -> Double {

        return 0.0
    }
}
