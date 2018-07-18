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
    var movies: [Movie?] = Array.init(repeating: nil, count: 164979)
    var users: [User] = []
    
    // Ratings: Y(movie, user) = 0.5 - 5
    var Y: matrix = zeros((164979, 671))
    
    // Binary value: R(movie, user) = 1 if rated, 0 if not
    var R: matrix = zeros((164979, 671))
    
    // Binary value: X(movie, user) = 1 if has that genre, 0 if not
    var X: matrix = zeros((164979, 19))
    
    // Binary value: X(movie, user) = 1 if has that genre, 0 if not
    var theta: matrix = rand((671, 19))
    
 /* ----------------------------------------------------------------------------------------------------
     Other Stuff:
         nm: # of movies = 164979
         nu: # of users = 671
         n : # of features = 18 - 0 based
     
    ---------------------------------------------------------------------------------------------------- */
    
    func importAndParseData() {
        importAndParseMovies()
        importAndParseRatings()
    }
    
    private func importAndParseMovies() {
        guard let text = importCSV("movies") else { return }
        parseMovie(text)
        print("Swoosh")
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
        var i = 0
        text.enumerateLines { (line, _) in
            let movieArray = line.components(separatedBy: ",")
            
            if let id = Int(movieArray[0]) {
                let title = movieArray[1]
                let genres = movieArray[2].components(separatedBy: "|")
                let movie = Movie(id: id, title: title, genres: genres)
                self.movies[id - 1] = movie
                self.X[i, 0..<19] = movie.features
                i+=1
            }
        }
    }
    
    private func parseRating(_ text: String) {
        var user = User(id: 1, theta: self.theta[0, "all"])
        
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
        Y[movieID - 1, uID - 1] = rating
        R[movieID - 1, uID - 1] = 1
        let movie = self.movies[movieID - 1]
        movie!.addRating(rating, for: uID)
        
        if user.id == 671 {
            self.users[670].addRating(rating, for: movieID)
        } else {
            user.addRating(rating, for: movieID)
        }
    }
    
    private func addRatingsForNewUser(_ user: inout User, with uID: Int, _ movieID: Int, _ rating: Double) {
        Y[movieID - 1, uID - 1] = rating
        R[movieID - 1, uID - 1] = 1
        let movie = self.movies[movieID - 1]
        movie!.addRating(rating, for: uID)
        
        self.users.append(user)
        user = User(id: uID, theta: self.theta[uID - 1, "all"])
        user.addRating(rating, for: movieID)
        if user.id == 671 {
            self.users.append(user)
        }
    }
}
