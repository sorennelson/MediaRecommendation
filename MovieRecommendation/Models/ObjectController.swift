//
//  ObjectController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 4/20/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import FirebaseAuth


class ObjectController {
    
    static var sharedInstance = ObjectController()
    static var currentMediaType = MediaType.Movies
    var currentUser: User?
    
    var movies: [Int: Movie] = Dictionary.init() // YID: Movie
    var movieLinks = [Int: String]() // YID: Link
    var movieUsers: [RatingUser] = []
    var genreMovies: [String: [Int]] = [:] // [genre: [movieIDs]]
    var movieRM: RecommenderModel?
    
    var books: [Int: Book] = [:]
    var allBookGenres: [String] = []
//    var bookGenres: [Int: [String]] = [:] // [bookID: [genres]]
    var genreBooks: [String: [Int]] = [:] // [genre: [bookIDs]]
    var bookUsers: [RatingUser] = []
    var bookRM: RecommenderModel?
    
    func getAllMedia() -> [Int: Media] {
        switch ObjectController.currentMediaType {
        case .Books:
            return books
        case .Movies:
            return movies
        }
    }
    
    func getAllMediaCount() -> Int {
        switch ObjectController.currentMediaType {
        case .Books:
            return books.count
        case .Movies:
            return movies.count
        }
    }
    
    func getAllMedia(for index: Int) -> Media? {
        switch ObjectController.currentMediaType {
        case .Books:
            return books[index]
        case .Movies:
            return movies[index]
        }
    }
    
    func getAllMedia(for indices: Range<Int>) -> [Media] {
        var media = [Media]()
        switch ObjectController.currentMediaType {
        case .Books:
            for i in indices {
                if let book = books[i] {
                    media.append(book)
                }
            }
            return media
            
        case .Movies:
            for i in indices {
                if let movie = movies[i] {
                    media.append(movie)
                }
            }
            return media
        }
    }
    
    func getPrediction(for user: RatingUser, media: Media) -> Double {
        var prediction: Double
        switch ObjectController.currentMediaType {
        case .Books:
            prediction = bookRM?.predict(media: media.yID, user: user.id) ?? 0.0
            
        case .Movies:
            prediction = movieRM?.predict(media: media.yID, user: user.id) ?? 0.0
        }
        return prediction
    }
    
//    User Authentication
    func createUser(email: String, password: String, completion: @escaping (Bool) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            }
            guard let authResult = authResult else {
                completion(false)
                return
            }
                
            self.currentUser = User(firID: authResult.user.uid,
                                    ubid: self.bookUsers.count, numBooks: self.books.count,
                                    umid: self.movieUsers.count, numMovies: self.movies.count)
            self.bookUsers.append(self.currentUser!.bookRatingUser!)
            self.movieUsers.append(self.currentUser!.movieRatingUser!)
            
//                TODO: Save User to database
            
            
            print(authResult)
            completion(true)
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            }
            
            if let authResult = authResult {
                
//                TODO: Get User from firebase
                print(authResult.user)
                
            } else {
                completion(true)
            }
        }
    }
    
    private func signIn(result: AuthDataResult) {
        
    }
    
}
