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
    
    var addedRatings = false
    
    var movies: [Movie] = [] // YID: Movie
    var recommendedMovies: [Movie] = []
    
    var genreMovies: [String: [Int]] = [:] // [genre: [movieIDs]]
    var movieRatings: [Media: Double]?
    
    var books: [Book] = []
    var allBookGenres: [String] = []
    //    var bookGenres: [Int: [String]] = [:] // [bookID: [genres]]
    var bookRatings: [Media: Double]?
    
    var selectedMedia: Media?
    var selectedMediaPrediction: Double?
    
    
    func getAllMedia() -> [Int: Media]? {

        return nil
    }
    
    func getAllMediaCount() -> Int {

        return 0
    }
    
    func getAllMedia(for index: Int) -> Media? {

        return nil
    }
    
    func getAllMedia(for indices: Range<Int>) -> [Media]? {

        return nil
    }
    
    func getMediaSortedByTopPredictions(genreName: String, user: User) -> [Media]? {

        return nil
    }
    
    func getRatings() -> [Media: Double]? {
        
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
