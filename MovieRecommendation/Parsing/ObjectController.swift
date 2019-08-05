//
//  ObjectController.swift
//  MediaRecommendation
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
    var movieGenres: [Genre] = []
    var genreMovies: [String: [Movie]] = [:]
    var mostRecentMovies: [Movie] = []
    var mostViewedMovies: [Movie] = []
    var seriesMovies: [MovieSeries] = []
    
    var allBooks: [Book] = []
    var recommendedBooks: [Book] = []
    var bookGenre: [Genre] = []
    var genreBooks: [String: [Book]] = [:]
    var mostRecentBooks: [Book] = []
    var mostViewedBooks: [Book] = []
    var seriesBooks: [BookSeries] = []
    
    var selectedMedia: Media?
    var selectedMediaPrediction: Double?
    
    func noRecommendations() -> Bool {
        return ObjectController.currentMediaType == .Books ? recommendedBooks.count == 0 : recommendedMovies.count == 0
    }
        
    func getMedia(for indices: Range<Int>) -> [Media] {
        if let _ = User.current {
            switch ObjectController.currentMediaType {
            case .Books:
                if recommendedBooks.count > 0  {  return getMedia(for: indices, in: recommendedBooks)  }
                else {  return getMedia(for: indices, in: allBooks)  }
                
            case .Movies:
                if recommendedMovies.count > 0 {  return getMedia(for: indices, in: recommendedMovies)  }
                else {  return getMedia(for: indices, in: allMovies)  }
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
    
    func getAllMedia() -> [Media] {
        if noRecommendations() {
            return ObjectController.currentMediaType == .Books ? allBooks : allMovies
        } else {
            return ObjectController.currentMediaType == .Books ? recommendedBooks : recommendedMovies
        }
    }
    
//    MARK: RATINGS
    func getRating(for media: Media) -> Float? {
        if ObjectController.currentMediaType == .Books {
            guard let user = User.current, let ratings = user.bookRatings else { return nil }
            for rating in ratings {
                if rating.book.id == media.id  {  return rating.rating  }
            }
            
        } else {
            guard let user = User.current, let ratings = user.movieRatings else { return nil }
            for rating in ratings {
                if rating.movie.id == media.id  {  return rating.rating  }
            }
        }
        return nil
    }
    
    func addRating(_ rating: Float, for media: Media, completion:@escaping (Bool, String) -> ()) -> Bool {
        let success = addLocalRating(rating, for: media)
        if !success  {  return false  }
        // TODO: Post rating to DB
        ImportController.sharedInstance.post(rating: rating, for: media) { (success, err) in
            completion(success, err)
        }
        return true
    }
    
    private func addLocalRating(_ rating: Float, for media: Media) -> Bool {
        guard let user = User.current else { return false }
        if ObjectController.currentMediaType == .Books {
            if let _ = user.bookRatings {
                if let i = user.bookRatings!.firstIndex(of: BookRating(book: media as! Book, rating: 0.0)) {
                    user.bookRatings![i].rating = rating
                } else {
                    user.bookRatings!.insert(BookRating(book: media as! Book, rating: rating), at: 0)
                }
            } else {
                user.bookRatings = [BookRating(book: media as! Book, rating: rating)]
            }
        } else {
            if let _ = user.movieRatings {
                if let i = user.movieRatings!.firstIndex(of: MovieRating(movie: media as! Movie, rating: 0.0)) {
                    user.movieRatings![i].rating = rating
                } else {
                    user.movieRatings!.insert(MovieRating(movie: media as! Movie, rating: rating), at: 0)
                }
            } else {
                user.movieRatings = [MovieRating(movie: media as! Movie, rating: rating)]
            }
        }
        return true
    }
    
//     MARK: Genres
    func getGenreCount() -> Int {
        if ObjectController.currentMediaType == .Books  {  return bookGenre.count  }
        else  {  return movieGenres.count  }
    }
    
    func getGenre(at index: Int) -> Genre? {
        if ObjectController.currentMediaType == .Books && bookGenre.count > 0    {  return bookGenre[index]  }
        if ObjectController.currentMediaType == .Movies && movieGenres.count > 0  {  return movieGenres[index]  }
        return nil
    }
    
    func getMediaForGenre(withName genreName: String, for indices: Range<Int>) -> [Media]? {
        if genreName == "All"  {  return getMedia(for: indices)  }
        
        if ObjectController.currentMediaType == .Books && genreBooks.keys.contains(genreName) {
            return self.getMedia(for: indices, in: genreBooks[genreName]!)
        }
        if ObjectController.currentMediaType == .Movies && genreMovies.keys.contains(genreName) {
            return self.getMedia(for: indices, in: genreMovies[genreName]!)
        }
        
        return nil
    }
    
    /// Imports the given Genre's Media
    ///
    /// - Parameters:
    ///   - categoryName: String
    ///   - mediaType: MediaType
    ///   - completion: [Media]? -- nil if their was an issue importing
    func getMediaForGenre(withName genreName: String, completion:@escaping ([Media]?) -> ()) {
        ImportController.sharedInstance.loadGenreMedia(for: genreName, of: ObjectController.currentMediaType) { (success, err, media) in
            if !success {
                print(err)
                completion(nil)
            }
            else {
                if ObjectController.currentMediaType == .Books { self.genreBooks[genreName] = media as? [Book] }
                else { self.genreMovies[genreName] = media as? [Movie] }
                completion(media)
            }
        }
    }
    
//     MARK: Most Recent
    func setMostRecent() {
        if ObjectController.currentMediaType == .Books {
            mostRecentBooks = getAllMedia().sorted(by: { (left, right) -> Bool in
                return left.year > right.year
            }) as! [Book]
            mostRecentBooks = Array(mostRecentBooks.prefix(99))
            
        } else {
            mostRecentMovies = getAllMedia().sorted(by: { (left, right) -> Bool in
                return left.year > right.year
            }) as! [Movie]
            mostRecentMovies = Array(mostRecentMovies.prefix(99))
        }
    }
    
    func getMostRecent(for indices: Range<Int>) -> [Media] {
        return getMedia(for: indices, in: ObjectController.currentMediaType == .Books ? mostRecentBooks : mostRecentMovies)
    }
    
    func getMostRecentCount() -> Int {
        return ObjectController.currentMediaType == .Books ? mostRecentBooks.count : mostRecentMovies.count
    }
    
//     MARK: Most Viewed
    func setMostViewed() {
        if ObjectController.currentMediaType == .Books {
            mostViewedBooks = getAllMedia().sorted(by: { (left, right) -> Bool in
                return left.numViewed > right.numViewed
            }) as! [Book]
            mostViewedBooks = Array(mostViewedBooks.prefix(30))
            
        } else {
            mostViewedMovies = getAllMedia().sorted(by: { (left, right) -> Bool in
                return left.numViewed > right.numViewed
            }) as! [Movie]
            mostViewedMovies = Array(mostViewedMovies.prefix(30))
        }
    }
    
    func getMostViewed(for indices: Range<Int>) -> [Media] {
        return getMedia(for: indices, in: ObjectController.currentMediaType == .Books ? mostViewedBooks : mostViewedMovies)
    }
    
    func getMostViewedCount() -> Int {
        return ObjectController.currentMediaType == .Books ? mostViewedBooks.count : mostViewedMovies.count
    }
    
//    MARK: Series
    func getBookSeries(for indices: Range<Int>) -> [BookSeries] {
        var series = [BookSeries]()
        for i in indices {
            if seriesBooks.indices.contains(i) {
                series.append(seriesBooks[i])
            }
        }
        return series
    }
    
    func getMovieSeries(for indices: Range<Int>) -> [MovieSeries] {
        var series = [MovieSeries]()
        for i in indices {
            if seriesMovies.indices.contains(i) {
                series.append(seriesMovies[i])
            }
        }
        return series
    }
    
    func getSeriesCount() -> Int {
        return ObjectController.currentMediaType == .Books ? seriesBooks.count : seriesMovies.count
    }
}
