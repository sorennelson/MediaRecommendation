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
    func loadAllMedia(_ mediaType: MediaType, completion:@escaping (Bool, String) -> ()) {
        
        let requestString = API_HOST + (mediaType == .Movies ? "movies" : "books") + "/all/"
        loadData(requestString: requestString, params:nil) { (success, str, data) in
            
            if !success { completion(false, str) }
            guard let data = data else { completion(false, "No Data Error"); return }
            
            do {
                if mediaType == .Movies {
                    let movies = try JSONDecoder().decode([Movie].self, from: data)
                    ObjectController.sharedInstance.movies = movies
                    completion(true, str)
                    
                } else {
                    let books = try JSONDecoder().decode([Book].self, from: data)
                    ObjectController.sharedInstance.books = books
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
                    ObjectController.sharedInstance.books = books
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
    func loadRatings(_ mediaType:MediaType, completion:@escaping (Bool, String) -> ()) {
        
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
