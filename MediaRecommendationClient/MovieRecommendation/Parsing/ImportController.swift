//
//  ImportController.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 1/10/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Alamofire

class ImportController {
    
    static let sharedInstance = ImportController()
    
    /// Loads the recommended media or all media (sorted by highest avg, title) depending on whether their is a current user or not.
    /// Then loads the user ratings and media Genre's
    /// If their is an error loading the recommended media, attempts to load all media.
    /// Call before using media.
    ///
    /// - Parameter completion: (was media successful to load bool, were ratings successful to load bool, were genres successful to load bool)
    func loadMediaRatingsAndGenres(_ mediaType: MediaType, completion:@escaping (Bool, Bool, Bool) -> ()) {
        var completeCount = 0
        var mediaLoaded = false
        var ratingsLoaded = false
        var genresLoaded = false

        if let _ = User.current {
            ImportController.sharedInstance.loadRecommended(0, to: 500, mediaType) { (success, error) in
                if !success || ObjectController.sharedInstance.noRecommendations() {
                    ImportController.sharedInstance.loadAllMedia(mediaType) { (success, error) in
                        //            TODO: Handle error
                        if success {
                            mediaLoaded = true
                        }
                        if self.isComplete(mediaType, &completeCount) {
                            completion(mediaLoaded, ratingsLoaded, genresLoaded)
                        }
                    }
                } else {
                    mediaLoaded = true
                    
                    // Still need to load all media but no need to wait on it
                    // TODO: Handle error
                    ImportController.sharedInstance.loadAllMedia(mediaType) { (success, error) in
                        if success && completeCount == 3 {
                            self.removeRatingsFromAllMedia(of: mediaType)
                        }
                    }
                    
                    if self.isComplete(mediaType, &completeCount) {
                        completion(mediaLoaded, ratingsLoaded, genresLoaded)
                    }
                }
            }
        } else {
            ImportController.sharedInstance.loadAllMedia(mediaType) { (success, error) in
                //            TODO: Handle error
                if success {
                    mediaLoaded = true
                }
                if self.isComplete(mediaType, &completeCount) {
                    completion(mediaLoaded, ratingsLoaded, genresLoaded)
                }
            }
        }
        
        ImportController.sharedInstance.loadRatings(mediaType) { (success, error) in
//            TODO: Handle error
            if success {
                ratingsLoaded = true
            }
            if self.isComplete(mediaType, &completeCount) {
                completion(mediaLoaded, ratingsLoaded, genresLoaded)
            }
        }
        
        ImportController.sharedInstance.loadAllGenres(of: mediaType) { (success, error) in
//            TODO: Handle error
            if success {
                genresLoaded = true
            }
            if self.isComplete(mediaType, &completeCount) {
                completion(mediaLoaded, ratingsLoaded, genresLoaded)
            }
        }
    }
    
    private func isComplete(_ mediaType: MediaType, _ completeCount: inout Int) -> Bool {
        completeCount += 1
        let done = completeCount == 3
        if done {
            removeRatingsFromAllMedia(of: mediaType)
        }
        return done
    }
    
    /// Forms an Alamofire request and gives back the data if their is any, and any error description
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
            
            if !success {
                completion(false, str) }
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
                    ObjectController.sharedInstance.recommendedBooks = books
                    completion(true, str)
                }
                
            } catch let error {
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    /// Load a single recommendation for the given media.
    ///
    /// - Parameters:
    ///   - media: Media
    ///   - completion: (success bool, error description, prediction float)
    func loadRecommendation(media:Media, completion:@escaping (Bool, String, Float?) -> ()) {
        let mediaType = ObjectController.currentMediaType
        guard let user = User.current else { completion(false, "No User", nil); return }
        let mediaIdStr = mediaType == .Movies ? "movieId" : "bookId"
        let params = ["id":user.id, mediaIdStr:media.id] as [String:Any]

        let requestString = API_HOST + (mediaType == .Movies ? "movies" : "books") + "/predictions/get_prediction/"
        loadData(requestString: requestString, params:params) { (success, str, data) in
            
            if !success { completion(false, str, nil) }
            guard let data = data else { completion(false, "No Data Error", nil);  return }
            
            do {
                
                if mediaType == .Movies {
                    let prediction = try JSONDecoder().decode([String:Float].self, from: data)["prediction"]
                    completion(true, str, prediction)
                    
                } else {
                    let prediction = try JSONDecoder().decode([String:Float].self, from: data)["prediction"]
                    completion(true, str, prediction)
                }
                
            } catch let error {
                print(error)
                completion(false, error.localizedDescription, nil)
            }
        }
    }
    
    /// Load the User Ratings
    ///
    /// - Parameters:
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
    
    /// Remove any media that has been rated from recommended and all media.
    ///
    /// - Parameters:
    ///   - mediaType: MediaType
    func removeRatingsFromAllMedia(of mediaType: MediaType) {
        if mediaType == .Books {
            guard let ratings = User.current?.bookRatings else { return }
            let ratingMedia = ratings.map { $0.book }
            
            if ObjectController.sharedInstance.recommendedBooks.count > 0 {
                ObjectController.sharedInstance.recommendedBooks.removeAll(where: { ratingMedia.contains($0) })
            }
            if ObjectController.sharedInstance.allBooks.count > 0 {
                ObjectController.sharedInstance.allBooks.removeAll(where: { ratingMedia.contains($0) })
            }
        } else {
            guard let ratings = User.current?.movieRatings else { return }
            let ratingMedia = ratings.map { $0.movie }
            
            if ObjectController.sharedInstance.recommendedMovies.count > 0 {
                ObjectController.sharedInstance.recommendedMovies.removeAll(where: { ratingMedia.contains($0) })
            }
            if ObjectController.sharedInstance.allMovies.count > 0 {
                ObjectController.sharedInstance.allMovies.removeAll(where: { ratingMedia.contains($0) })
            }
        }
    }
    
    /// Load the media genres.
    /// Does not load the media for each genre (see loadGenreMedia()).
    ///
    /// - Parameters:
    ///   - mediaType: MediaType
    ///   - completion: (success bool, error description)
    func loadAllGenres(of mediaType: MediaType, completion:@escaping (Bool, String) -> ()) {
        let requestString = API_HOST + (mediaType == .Movies ? "movies" : "books") + "/genres/"
        loadData(requestString: requestString, params:nil) { (success, str, data) in
            
            if !success { completion(false, str) }
            guard let data = data else { completion(false, "No Data Error");  return }
            
            do {
                let genres = try JSONDecoder().decode([Genre].self, from: data)
                
                if mediaType == .Books { ObjectController.sharedInstance.bookGenre = genres }
                else {  ObjectController.sharedInstance.movieGenres = genres}
                completion(true, str)
                
            } catch let error {
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    /// Load the media for the given genre title. Removes any ratings from the genre media.
    ///
    /// - Parameters:
    ///   - genre: String. The genre title.
    ///   - mediaType: MediaType
    ///   - completion: (success bool, error description)
    func loadGenreMedia(for genre: String, of mediaType: MediaType, completion:@escaping (Bool, String, [Media]) -> ()) {
        let params: [String: Any]
        if let current = User.current {
            params = ["name":genre, "id":current.id]
        } else {
            params = ["name":genre]
        }
        
        let requestString = API_HOST + (mediaType == .Movies ? "movies" : "books") + "/genres/get_genre_media/"
        loadData(requestString: requestString, params:params) { (success, str, data) in
            
            if !success { completion(false, str, []) }
            guard let data = data else { completion(false, "No Data Error", []);  return }
            
            do {
                
                if mediaType == .Movies {
                    var movies = try JSONDecoder().decode([Movie].self, from: data)
                    
                    // Remove any rated from genre
                    if let ratings = User.current?.movieRatings {
                        let ratingMedia = ratings.map { $0.movie }
                        movies.removeAll(where: { ratingMedia.contains($0) })
                        completion(true, str, movies)
                    }
                    completion(true, str, movies)
                    
                } else {
                    var books = try JSONDecoder().decode([Book].self, from: data)
                    
                    // Remove any rated from genre
                    if let ratings = User.current?.bookRatings {
                        let ratingMedia = ratings.map { $0.book }
                        books.removeAll(where: { ratingMedia.contains($0) })
                        completion(true, str, books)
                    }
                    completion(true, str, books)
                }
                
            } catch let error {
                print(error)
                completion(false, error.localizedDescription, [])
            }
        }
        
    }
    
    /// Loads all series of the current media type.
    ///
    /// - Parameters:
    ///   - completion: (success bool, error description)
    func loadSeries(completion:@escaping (Bool, String) -> ()) {
        let requestString = API_HOST + (ObjectController.currentMediaType == .Movies ? "movies" : "books") + "/series/"
        loadData(requestString: requestString, params: nil) { (success, str, data) in
            
            if !success { completion(false, str) }
            guard let data = data else { completion(false, "No Data Error");  return }
            
            do {
                if ObjectController.currentMediaType == .Movies {
                    let series = try JSONDecoder().decode([MovieSeries].self, from: data)
                    ObjectController.sharedInstance.seriesMovies = series
                    completion(true, str)
                    
                } else {
                    let series = try JSONDecoder().decode([BookSeries].self, from: data)
                    ObjectController.sharedInstance.seriesBooks = series
                    completion(true, str)
                }
                
            } catch let error {
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    /// Sends a post request to the server to add a new rating on the given media for the logged in user.
    ///
    /// - Parameters:
    ///   - rating: Float
    ///   - media: Media
    ///   - completion: (success bool, error description)
    func post(rating: Float, for media: Media, completion:@escaping (Bool, String) -> ()) {
        let params: [String: Any]
        if ObjectController.currentMediaType == .Books {
            params = ["id": User.current!.id, "rating": rating, "book": media.id]
        } else {
            params = ["id": User.current!.id, "rating": rating, "movie": media.id]
        }
    
        let requestString = API_HOST + (ObjectController.currentMediaType == .Movies ? "movies" : "books") + "/ratings/new/"
        Alamofire.request(requestString, method: .post, parameters:params).responseData { (response) in
            switch response.result {
            case .success:
                
                switch response.response?.statusCode ?? -1 {
                case 201:
                    completion(true, "Success")
                default:
                    completion(false, "Error posting rating")
                }
                
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    
}
