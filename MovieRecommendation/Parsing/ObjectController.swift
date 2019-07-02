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
    var currentUser: User?
    
    var addedRatings = false
    
    var allMoviesArr: [Movie] = []
    var movies: [Int: Movie] = Dictionary.init() // YID: Movie
    var movieLinks = [Int: String]() // YID: Link
    var genreMovies: [String: [Int]] = [:] // [genre: [movieIDs]]
    var movieUsers: [User] = []
    var movieRatings: [Media: Double]?
    var movieRM: RecommenderModel?
    
    var allBooksArr: [Book] = []
    var books: [Int: Book] = [:]
    var allBookGenres: [String] = []
    //    var bookGenres: [Int: [String]] = [:] // [bookID: [genres]]
    var genreBooks: [String: [Int]] = [:] // [genre: [bookIDs]]
    var bookUsers: [User] = []
    var bookRatings: [Media: Double]?
    var bookRM: RecommenderModel?
    
    var selectedMedia: Media?
    var selectedMediaPrediction: Double?
    
    
    func getAllMedia() -> [Int: Media]? {
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            return books
        //        case .Movies:
        //            return movies
        //        }
        return nil
    }
    
    func getAllMediaCount() -> Int {
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            return books.count
        //        case .Movies:
        //            return allMoviesArr.count
        //        }
        return 0
    }
    
    func getAllMedia(for index: Int) -> Media? {
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            return books[index]
        //        case .Movies:
        //            return allMoviesArr[index]
        //        }
        return nil
    }
    
    func getAllMedia(for indices: Range<Int>) -> [Media]? {
        //        var media = [Media]()
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            for i in indices {
        //                if let book = books[i] {
        //                    media.append(book)
        //                }
        //            }
        //            return media
        //
        //        case .Movies:
        //            for i in indices {
        //                if i == allMoviesArr.count { break }
        //                media.append(allMoviesArr[i])
        //            }
        //            return media
        //        }
        return nil
    }
    
    
    //    func sortMediaByTopPredictions(_ type: MediaType, user: RatingUser) {
    //        switch type {
    //        case .Books:
    //
    //        case .Movies:
    //
    //        }
    //    }
    
    func getMediaSortedByTopPredictions(genreName: String, user: User) -> [Media]? {
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            var categoryBooks: [Media]
        //            if genreName == "All" {
        //                categoryBooks = allBooksArr
        //            } else {
        //                categoryBooks = getMediaForCategory(genreName: genreName)
        //            }
        //            return categoryBooks.sorted { (left, right) -> Bool in
        //                let leftPred = bookRM?.predict(media: left.yID, user: user.id) ?? 0.0
        //                let rightPred = bookRM?.predict(media: right.yID, user: user.id) ?? 0.0
        //                return leftPred >= rightPred
        //            }
        //
        //        case .Movies:
        //            var categoryMovies: [Media]
        //            if genreName == "All" {
        //                categoryMovies = allMoviesArr
        //            } else {
        //                categoryMovies = getMediaForCategory(genreName: genreName)
        //            }
        //            return categoryMovies.sorted { (left, right) -> Bool in
        //                let leftPred = movieRM?.predict(media: left.yID, user: user.id) ?? 0.0
        //                let rightPred = movieRM?.predict(media: right.yID, user: user.id) ?? 0.0
        //                return leftPred >= rightPred
        //            }
        //        }
        return nil
    }
    
    
    
    func getRatings() -> [Media: Double]? {
        //        guard let user = currentUser else { return [:] }
        //        var mediaRatings = [Media: Double]()
        //
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            if let ratings = bookRatings {
        //                return ratings
        //            }
        //            for rating in user.booksRated {
        //                if let book = books[rating.key] {
        //                    mediaRatings[book] = rating.value
        //                }
        //            }
        //            bookRatings = mediaRatings
        //            return mediaRatings
        
        //            let ratings = user.bookRatingUser!.ratings
        //            for i in 0..<ratings.count {
        //                if ratings[i] > 0.0 {
        //                    if let book = books[i] {
        //                        media[book] = user.booksRated[i]
        //                    }
        //                }
        //            }
        //        case .Movies:
        //            if let ratings = movieRatings {
        //                return ratings
        //            }
        //            for rating in user.moviesRated {
        //                if let movie = movies[rating.key] {
        //                    mediaRatings[movie] = rating.value
        //                }
        //            }
        //            movieRatings = mediaRatings
        //            return mediaRatings
        
        //            let ratings = user.movieRatingUser!.ratings
        //            for i in 0..<ratings.count {
        //                if ratings[i] > 0.0 {
        //                    if let movie = movies[i] {
        //                        mediaRatings[movie] = user.moviesRated[i]
        //                    }
        //                }
        //            }
        //        }
        return nil
    }
    
    func addRating(_ rating: Double, for media: Media) -> Bool {
        //        guard let user = currentUser else { return false }
        //        addedRatings = true
        //        user.rate(ObjectController.currentMediaType, with: media.yID, rating: rating)
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            books[media.yID]?.ratings[(user.bookRatingUser?.id)!] = rating                  // add rating to books[book]
        //            books[media.yID]?.numRatings! += 1.0
        //
        //            if let _ = bookRatings {
        //                bookRatings![media] = rating                                                // add rating to bookRatings
        //            }
        //
        //            var avg = books[media.yID]!.getAvgRating() * books[media.yID]!.numRatings!
        //            avg = (avg + rating) / books[media.yID]!.numRatings!                            // edit avg rating
        //
        //            if let _ = bookRM {
        //                bookRM?.updateRatings(at: media.yID, user.bookRatingUser!.id, with: rating) //  add rating to RM
        //            }
        //
        //        case .Movies:
        //            movies[media.yID]?.ratings[(user.movieRatingUser?.id)!] = rating
        //
        //            var avg = movies[media.yID]!.getAvgRating() * (movies[media.yID]!.numRatings! + 1)
        //            avg = (avg + rating) / movies[media.yID]!.numRatings!
        //
        //            movies[media.yID]?.numRatings! += 1.0
        //
        //            if let _ = movieRatings {
        //                movieRatings![media] = rating
        //            }
        //
        //            if let _ = movieRM {
        //                movieRM?.updateRatings(at: media.yID, user.bookRatingUser!.id, with: rating)
        //            }
        //        }
        return true
    }
    
    func getAllCategories() -> [String]? {
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            return Array(genreBooks.keys)
        //        case .Movies:
        //            var sorted = Array(genreMovies.keys).sorted()
        //            let noGenres = sorted.remove(at: 0)
        ////            sorted.append("No Genres Listed")
        //            sorted.append(noGenres)
        //            return sorted
        //        }
        return nil
    }
    
    func getMediaForCategory(genreName: String) -> [Media]? {
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            let ids = genreBooks[genreName] ?? []
        //            var media = [Media]()
        //            for id in ids {
        //                if let book = books[id] {
        //                    media.append(book)
        //                }
        //            }
        //            return media
        //
        //        case .Movies:
        //            let ids = genreMovies[genreName] ?? []
        //            var media = [Media]()
        //            for id in ids {
        //                if let movie = movies[id] {
        //                    media.append(movie)
        //                }
        //            }
        //            return media
        //        }
        return nil
    }
    
    func getCategoryCount(genreName: String) -> Int {
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            let ids = genreBooks[genreName] ?? []
        //            return ids.count
        //
        //        case .Movies:
        //            let ids = genreMovies[genreName] ?? []
        //            return ids.count
        //        }
        return 0
    }
    
    func getMediaForCategory(genreName: String, at indices: Range<Int>) -> [Media]? {
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            let ids = genreBooks[genreName] ?? []
        //            var media = [Media]()
        //            for i in indices {
        //                if i == ids.count { break }
        //                let id = ids[i]
        //                if let book = books[id] {
        //                    media.append(book)
        //                }
        //            }
        //            return media
        //
        //        case .Movies:
        //            let ids = genreMovies[genreName] ?? []
        //            var media = [Media]()
        //            for i in indices {
        //                if i == ids.count { break }
        //                let id = ids[i]
        //                if let movie = movies[id] {
        //                    media.append(movie)
        //                }
        //            }
        //            return media
        //        }
        return nil
    }
    
    func doneAddingRatings() {
        //        if addedRatings {
        //            print("ADDED")
        //        TODO: Run model again
        //        }
    }
    
    func getPrediction(for media: Media) -> Double {
        //        var prediction: Double
        //        switch ObjectController.currentMediaType {
        //        case .Books:
        //            prediction = bookRM?.predict(media: media.yID, user: user.id) ?? 0.0
        //
        //        case .Movies:
        //            prediction = movieRM?.predict(media: media.yID, user: user.id) ?? 0.0
        //        }
        //        return prediction
        return 0.0
    }
    
}
