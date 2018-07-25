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
    var delegate: RMDelegate?
    
    var movies: [Movie?] = Array.init(repeating: nil, count: 164979)
    var users: [User] = []
    
    func importAndParseData() {
        delegate?.createEmptyMatrices(movieCount: 164979, userCount: 671, featureCount: 18)
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
        var i = 0
        text.enumerateLines { (line, _) in
            let movieArray = line.components(separatedBy: ",")
            
            if let id = Int(movieArray[0]) {
                let title = movieArray[1]
                let genres = movieArray[2].components(separatedBy: "|")
                let movie = Movie(id: id, title: title, genres: genres)
                
                self.movies[id - 1] = movie
                self.delegate?.updateX(at: i, 0..<19, with: movie.features)
                i+=1
            }
        }
    }
    
    private func parseRating(_ text: String) {
        
        var user = User(id: 1, theta: delegate!.getParametersForUser(0))
        
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
        
        if user.id == 671 {
            self.users[670].addRating(rating, for: movieID)
        } else {
            user.addRating(rating, for: movieID)
        }
    }
    
    private func addRatingsForNewUser(_ user: inout User, with uID: Int, _ movieID: Int, _ rating: Double) {
        addRating(rating, for: uID, movieID)
        
        users.append(user)
        user = User(id: uID, theta: delegate!.getParametersForUser(0))
        user.addRating(rating, for: movieID)
        if user.id == 671 {
            self.users.append(user)
        }
    }
    
    private func addRating(_ rating: Double, for uID: Int, _ movieID: Int) {
        delegate?.updateRatings(at: movieID, uID, with: rating)
        guard let movie = movies[movieID - 1] else {
            print("Rating a nil Movie")
            return
        }
        movie.addRating(rating, for: uID)
    }
}
