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
    
    func importAndParseUser() {

        
//        guard let movieText = importFileAt("User_Data/Movie_Data", ofType: ".csv") else { return }
//        var movieUser = RatingUser(id: ObjectController.sharedInstance.movieUsers.count, numMedia: ObjectController.sharedInstance.movies.count)
//        var moviesRated = [Int: Double]()
//
//        movieText.enumerateLines { (line, _) in
//            let movie = line.components(separatedBy: ",")
//            if let id = Int(movie[0]),
//                let rating = Double(movie[1]) {
//                movieUser.addRating(rating, for: id)
//                moviesRated[id] = rating
//            }
//        }
//
//        guard let bookText = importFileAt("User_Data/Book_Data", ofType: ".csv") else { return }
//        var bookUser = RatingUser(id: ObjectController.sharedInstance.bookUsers.count, numMedia: ObjectController.sharedInstance.books.count)
//        var booksRated = [Int: Double]()
//
//        bookText.enumerateLines { (line, _) in
//            let book = line.components(separatedBy: ",")
//            if let id = Int(book[0]),
//                let rating = Double(book[1]) {
//                bookUser.addRating(rating, for: id)
//                booksRated[id] = rating
//            }
//        }
//
//        ObjectController.sharedInstance.currentUser = User(movieUser: movieUser, moviesRated: moviesRated, bookUser: bookUser, booksRated: booksRated)
    }
    
    func importToContentBasedMLModel<T: Media>(media: [Int:T], featureCount: Int) -> RecommenderModel {
        let temp = changeDictionaryToArray(media: media)
        return ImportController.sharedInstance.addMediaAndRatings(temp, for: ObjectController.sharedInstance.movieUsers, featureCount: featureCount)
    }
    
    func importToCollaborativeFilteringMLModel<T: Media>(mediaType: MediaType, media: [Int:T], featureCount: Int) -> RecommenderModel {
        let temp = changeDictionaryToArray(media: media)
        var users: [RatingUser]
        
        if mediaType == .Books {
            users = ObjectController.sharedInstance.bookUsers
            if let currUser = ObjectController.sharedInstance.currentUser?.bookRatingUser {
                users.append(currUser)
            }
            
        } else {
            users = ObjectController.sharedInstance.movieUsers
            if let currUser = ObjectController.sharedInstance.currentUser?.movieRatingUser {
                users.append(currUser)
            }
        }
        return ImportController.sharedInstance.addRatings(temp, for: users, featureCount: featureCount)
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
