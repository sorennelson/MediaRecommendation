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
    var movieCategories: [Category] = []
    var categoryMovies: [String: [Movie]] = [:]
    
    var allBooks: [Book] = []
    var recommendedBooks: [Book] = []
    var bookCategories: [Category] = []
    var categoryBooks: [String: [Book]] = [:]
    
    // Not currently using
    var addedRatings = false
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
    
//    func getMediaCount() -> Int {
//        if let _ = User.current {
//            return ObjectController.currentMediaType == .Books ? recommendedBooks.count : recommendedMovies.count
//        } else {
//            return getAllMediaCount()
//        }
//    }
//    
//    func getAllMediaCount() -> Int {
//        return ObjectController.currentMediaType == .Books ? allBooks.count : allMovies.count
//    }
    
    func getMedia(for index: Int) -> Media? {

        return nil
    }
    
    func addRating(_ rating: Double, for media: Media) -> Bool {
       
        return true
    }
    
    func doneAddingRatings() {
        
    }
    
    func getPrediction(for media: Media) -> Double {
        
        return 0.0
    }
    
    
//     MARK: Categories
    
    
    func getCategoryCount() -> Int {
        if ObjectController.currentMediaType == .Books  {  return bookCategories.count  }
        else  {  return movieCategories.count  }
    }
    
    func getCategory(at index: Int) -> Category? {
        if ObjectController.currentMediaType == .Books && bookCategories.count > 0    {  return bookCategories[index]  }
        if ObjectController.currentMediaType == .Movies && movieCategories.count > 0  {  return movieCategories[index]  }
        return nil
    }
    
    func getMediaForCategory(withName categoryName: String, for indices: Range<Int>) -> [Media]? {
        if categoryName == "All"  {  return getMedia(for: indices)  }
        
        if ObjectController.currentMediaType == .Books && categoryBooks.keys.contains(categoryName) {
            return self.getMedia(for: indices, in: categoryBooks[categoryName]!)
        }
        if ObjectController.currentMediaType == .Movies && categoryMovies.keys.contains(categoryName) {
            return self.getMedia(for: indices, in: categoryMovies[categoryName]!)
        }
        
        return nil
    }
    
    /// Imports the given Category's Media
    ///
    /// - Parameters:
    ///   - categoryName: String
    ///   - mediaType: MediaType
    ///   - completion: [Media]? -- nil if their was an issue importing
    func getMediaForCategory(withName categoryName: String, completion:@escaping ([Media]?) -> ()) {
        ImportController.sharedInstance.loadCategoryMedia(for: categoryName, of: ObjectController.currentMediaType) { (success, err, media) in
            if !success {
                print(err)
                completion(nil)
            }
            else {
                if ObjectController.currentMediaType == .Books { self.categoryBooks[categoryName] = media as? [Book] }
                else { self.categoryMovies[categoryName] = media as? [Movie] }
                completion(media)
            }
        }
    }
}
