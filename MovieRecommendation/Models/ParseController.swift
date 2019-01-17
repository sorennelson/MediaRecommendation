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
    
    var movies: [Int: Movie] = Dictionary.init()
    var users: [User] = []
    
    func importAndParseData() {
        importAndParseMovies()
        importAndParseRatings()
    }
    
    private func importAndParseMovies() {
        guard let text = importCSV("movies") else { return }
        parseMovie(text)
    }
    
    private func importAndParseRatings() {
        guard let text = importCSV("ratings") else { return }
        parseRating(text)
    }
    
    private func importCSV(_ type: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Movie_Data/\(type)", ofType: "csv") else {
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
    
    private func parseMovie(_ text: String) {
        var i = 1
        text.enumerateLines { (line, _) in
            let movieArray = line.components(separatedBy: ",")
            
            if let id = Int(movieArray[0]) {
                let title = movieArray[1]
                let genres = movieArray[2].components(separatedBy: "|")
                let movie = Movie(id: i, title: title, genres: genres)
                
                self.movies[id] = movie
                i+=1
            }
        }
    }
    
    private func parseRating(_ text: String) {
        var user = User(id: 1)
        
        text.enumerateLines { (line, _) in
            let ratingArray = line.components(separatedBy: ",")
            
            if let uID = Int(ratingArray[0]),
               let movieID = Int(ratingArray[1]),
               let rating = Double(ratingArray[2]) {
                
                if user.id == uID {
                    self.addRatingsForCreatedUser(&user, with: uID, movieID, rating)
                    
                } else {
                    self.addRatingsForNewUser(&user, with: uID, movieID, rating)
                }
            }
        }
    }
    
    private func addRatingsForCreatedUser(_ user: inout User, with uID: Int, _ movieID: Int, _ rating: Double) {
        addRating(rating, for: uID, movieID)
        
        var mID = movieID
        getMID(&mID)
        
        if user.id == 671 {
            self.users[670].addRating(rating, for: mID)
        } else {
            user.addRating(rating, for: mID)
        }
    }
    
    private func addRatingsForNewUser(_ user: inout User, with uID: Int, _ movieID: Int, _ rating: Double) {
        addRating(rating, for: uID, movieID)
        
        users.append(user)
        user = User(id: uID)
        
        var mID = movieID
        getMID(&mID)
        
        user.addRating(rating, for: mID)
        if user.id == 671 {
            self.users.append(user)
        }
    }
    
    private func addRating(_ rating: Double, for uID: Int, _ movieID: Int) {
        guard let _ = movies[movieID] else {
            print("Rating a nil Movie")
            return
        }

        movies[movieID]!.addRating(rating, for: uID)
    }
    
    /**
     Used to swap from moviesID to yID
     **/
    private func getMID(_ movieID: inout Int) {
        guard let movie = movies[movieID] else {
            print("Rating a nil Movie")
            return
        }
        movieID = movie.yID
    }
    
    func importToMLModel() -> RecommenderModel {
        let temp = changeDictionaryToArray()
        return ImportController.sharedInstance.addMedia(temp, for: users, featureCount: 19)
    }
    
    private func changeDictionaryToArray() -> [Movie] {
        var keys = Array(movies.keys)
        keys = keys.sorted()
        var temp = [Movie]()
        
        for key in keys {
            if let movie = movies[key] {
                temp.append(movie)
            }
        }
        return temp
    }
    
}
