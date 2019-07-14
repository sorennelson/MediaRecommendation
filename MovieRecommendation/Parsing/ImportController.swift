//
//  ImportController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 1/10/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Alamofire

class ImportController {
    
    static let sharedInstance = ImportController()
    
    /// Loads either the recommended movies or all media (sorted by highest avg, title) depending on whether their is a current user or not.
    /// If their is an error loading the recommended media, or the model is not done recommending, attempts to load all media.
    /// Call before using media.
    ///
    /// - Parameter completion: (was media successful to load bool, were ratings successful to load bool)
    func loadMediaAndRatings(_ mediaType: MediaType, completion:@escaping (Bool, Bool) -> ()) {
        var completeCount = 0
        var mediaLoaded = false
        var ratingsLoaded = false
        
        if let _ = User.current {
            ImportController.sharedInstance.loadRecommended(0, to: 300, mediaType) { (success, error) in
                if !success || ObjectController.sharedInstance.noRecommendations() {
                    ImportController.sharedInstance.loadAllMedia(mediaType) { (success, error) in
                        //            TODO: Handle error
                        if success {
                            mediaLoaded = true
                        }
                        if self.isComplete(&completeCount) {
                            completion(mediaLoaded, ratingsLoaded)
                        }
                    }
                } else {
                    //            TODO: Handle error
                    mediaLoaded = true
                    if self.isComplete(&completeCount) {
                        completion(mediaLoaded, ratingsLoaded)
                    }
                }
            }
        } else {
            ImportController.sharedInstance.loadAllMedia(mediaType) { (success, error) in
                //            TODO: Handle error
                if success {
                    mediaLoaded = true
                }
                if self.isComplete(&completeCount) {
                    completion(mediaLoaded, ratingsLoaded)
                }
            }
        }
        
        ImportController.sharedInstance.loadRatings(mediaType) { (success, error) in
            //            TODO: Handle error
            if success {
                ratingsLoaded = true
            }
            if self.isComplete(&completeCount) {
                completion(mediaLoaded, ratingsLoaded)
            }
        }
    }
    
    private func isComplete(_ completeCount: inout Int) -> Bool {
        completeCount += 1
        return completeCount == 2
    }
    
    /// Forms an Alamofire request and gives back the data if their is any and any error description
    ///
    /// - Parameters:
    ///   - requestString: String. The full http request string
    ///   - params: [String:Any]?. The request parameters, if any
    ///   - completion: (success, error code, data?)
    private func loadData(requestString: String, params: [String:Any]?, completion:@escaping (Bool, String, Data?) -> ()) {
        
        Alamofire.request(requestString, parameters:params).responseData { (response) in
            switch response.result {
                
            case .success(let data):
                switch response.response?.statusCode ?? -1 {
                case 200:
                    completion(true, "Success", data)
                default:
                    completion(false, "Unexpected Error", data)
                }
                
            case .failure(let error):
                completion(false, error.localizedDescription, nil)
            }
        }
    }
    
    /// Loads all media of the given type.
    ///
    /// - Parameters:
    ///   - mediaType: MediaType.
    ///   - completion: (success bool, error description)
    private func loadAllMedia(_ mediaType: MediaType, completion:@escaping (Bool, String) -> ()) {
        
        let requestString = API_HOST + (mediaType == .Movies ? "movies" : "books") + "/all/"
        loadData(requestString: requestString, params:nil) { (success, str, data) in
            
            if !success { completion(false, str) }
            guard let data = data else { completion(false, "No Data Error"); return }
            
            do {
                if mediaType == .Movies {
                    let movies = try JSONDecoder().decode([Movie].self, from: data)
                    ObjectController.sharedInstance.allMovies = movies
                    completion(true, str)
                    
                } else {
                    let books = try JSONDecoder().decode([Book].self, from: data)
                    ObjectController.sharedInstance.allBooks = books
                    completion(true, str)
                }
            } catch let error {
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    
    /// Load the top recommended media of given type for given indexes [n, m).
    ///
    /// - Parameters:
    ///   - n: Int. start index
    ///   - m: Int. end index
    ///   - mediaType: MediaType
    ///   - completion: (success bool, error description)
    func loadRecommended(_ n: Int, to m:Int, _ mediaType:MediaType, completion:@escaping (Bool, String) -> ()) {
        
        guard let user = User.current else { completion(false, "No User"); return }
        
        let params = ["start": n, "end": m, "id":user.id] as [String:Any]
        let requestString = API_HOST + (mediaType == .Movies ? "movies" : "books") + "/all/get_top_recommendations/"
        loadData(requestString: requestString, params:params) { (success, str, data) in
            
            if !success { completion(false, str) }
            guard let data = data else { completion(false, "No Data Error");  return }
            
            do {
                
                if mediaType == .Movies {
                    let movies = try JSONDecoder().decode([Movie].self, from: data)
                    ObjectController.sharedInstance.recommendedMovies = movies
                    completion(true, str)
                    
                } else {
                    let books = try JSONDecoder().decode([Book].self, from: data)
                    ObjectController.sharedInstance.allBooks = books
                    completion(true, str)
                }
                
            } catch let error {
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    /// Load the top recommended media of given type for given indexes [n, m).
    ///
    /// - Parameters:
    ///   - n: Int. start index
    ///   - m: Int. end index
    ///   - mediaType: MediaType
    ///   - completion: (success bool, error description)
    private func loadRatings(_ mediaType:MediaType, completion:@escaping (Bool, String) -> ()) {
        
        guard let user = User.current else { completion(false, "No User"); return }
        
        let params = ["id":user.id] as [String:Any]
        let requestString = API_HOST + (mediaType == .Movies ? "movies" : "books") + "/ratings/get_user_ratings/"
        loadData(requestString: requestString, params:params) { (success, str, data) in
            
            if !success { completion(false, str) }
            guard let data = data else { completion(false, "No Data Error");  return }
            
            do {
                
                if mediaType == .Movies {
                    let ratings = try JSONDecoder().decode([MovieRating].self, from: data)
                    User.current?.movieRatings = ratings
                    completion(true, str)
                    
                } else {
                    let ratings = try JSONDecoder().decode([BookRating].self, from: data)
                    User.current?.bookRatings = ratings
                    completion(true, str)
                }
                
            } catch let error {
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    
}
