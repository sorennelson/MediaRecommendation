//
//  MovieParser.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 4/14/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

class MovieParser {
    
    static let sharedInstance = MovieParser()
    private let objectController = ObjectController.sharedInstance
    
    // MARK: Details
    func importAndParseMovies() {
        guard let linkText = ParseController.sharedInstance.importFileAt("Movie_Data/links_to_images", ofType: "csv") else { return }
        parseMovieLinks(linkText)
        
        guard let movieText = ParseController.sharedInstance.importFileAt("Movie_Data/movies", ofType: "csv") else { return }
        parseMovies(movieText)
        
        guard let ratingText = ParseController.sharedInstance.importFileAt("Movie_Data/ratings", ofType: "csv") else { return }
        parseMovieRatings(ratingText)
        }
    
    private func parseMovies(_ text: String) {
        var i = 1
        text.enumerateLines { (line, _) in
            let movieArray = line.components(separatedBy: ",")
            
            if let mid = Int(movieArray[0]) {
                let title = movieArray[1]
                let genres = movieArray[2].components(separatedBy: "|")
                for genre in genres {
                    if let _ = self.objectController.genreMovies[genre] { self.objectController.genreMovies[genre]!.append(mid) }
                }
                let movie = Movie(yid: i, title: title, imageString: self.objectController.movieLinks[mid], genres: genres)
                
                self.objectController.movies[mid] = movie
                i+=1
            }
        }
    }
    
    private func parseMovieLinks(_ text: String) {
        text.enumerateLines { (line, _) in
            let movieArray = line.components(separatedBy: ",")
            
            if movieArray.count == 4 {
                if let mid = Int(movieArray[0]) {
                    let link = movieArray[3]
                    self.objectController.movieLinks[mid] = link
                }
            }
        }
    }
    
    // MARK: Ratings
    private func parseMovieRatings(_ text: String) {
        var user = User(id: 1, numMedia: 9125)
        
        text.enumerateLines { (line, _) in
            let ratingArray = line.components(separatedBy: ",")
            
            if let uID = Int(ratingArray[0]),
                let movieID = Int(ratingArray[1]),
                let rating = Double(ratingArray[2]) {
                
                if user.id == uID {
                    self.addMovieRatingsForCreatedUser(&user, with: uID, movieID, rating)
                    
                } else {
                    self.addMovieRatingsForNewUser(&user, with: uID, movieID, rating)
                }
            }
        }
    }
    
    private func addMovieRatingsForCreatedUser(_ user: inout User, with uID: Int, _ movieID: Int, _ rating: Double) {
        addMovieRating(rating, for: uID, movieID)
        
        var mID = movieID
        getMID(&mID)
        
        if user.id == 671 {
            objectController.movieUsers[670].addRating(rating, for: mID)
        } else {
            user.addRating(rating, for: mID)
        }
    }
    
    private func addMovieRatingsForNewUser(_ user: inout User, with uID: Int, _ movieID: Int, _ rating: Double) {
        addMovieRating(rating, for: uID, movieID)
        
        objectController.movieUsers.append(user)
        user = User(id: uID, numMedia: 9125)
        
        var mID = movieID
        getMID(&mID)
        
        user.addRating(rating, for: mID)
        if user.id == 671 {
            objectController.movieUsers.append(user)
        }
    }
    
    private func addMovieRating(_ rating: Double, for uID: Int, _ movieID: Int) {
        guard let _ = objectController.movies[movieID] else {
            print("Rating a nil Movie")
            return
        }
        objectController.movies[movieID]!.addRating(rating, for: uID)
    }
    
    /**
     Used to swap from moviesID to yID
     **/
    private func getMID(_ movieID: inout Int) {
        guard let movie = objectController.movies[movieID] else {
            print("Rating a nil Movie")
            return
        }
        movieID = movie.yID
    }
    
    
// MARK: Image Link
    
//    func getImageLinkWith(_ tmdbID: Int, completion:@escaping (String) -> ())  {
//        guard let url = URL(string: "https://api.themoviedb.org/3/movie/" + String(tmdbID) + "?api_key=60d78c7cfee3c407c714903efd4c3359&language=en-US") else {
//            print("Wrong URL")
//            return
//        }
//
//        let postData = NSData(data: "{}".data(using: .utf8)!)
//
//        var request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 90.0)
//        request.httpMethod = "GET"
//        request.httpBody = postData as Data
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
//            if let error = error {
//                print(error)
//                completion("")
//            } else {
//                if let httpResponse = response as? HTTPURLResponse {
//                    print(httpResponse)
//                    do {
//                        let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any]
//                        print(jsonResult!)
//                        let poster = jsonResult!["poster_path"] as! String
//                        print(poster)
//                        completion(poster)
//                    }
//                    catch {
//                        print("JSON ERROR")
//                        completion("")
//                    }
//
//                }
//                else {
//                    print("NO HTTP RESPONSE")
//                    completion("")
//                }
//
//            }
//        }
//
//        dataTask.resume()
//    }
    
//    func tempGetLinks(completion:@escaping () -> ()) {
//        guard let linkText = ParseController.sharedInstance.importFileAt("Movie_Data/links", ofType: "csv") else { return }
//        parseMovieLinks(linkText)
//        getLinks(linkText) {
//            //TODO: Write to csv
//            print("complete")
//            completion()
//        }
//    }
    
//    func getLinks(_ text: String, completion:@escaping () -> ()) {
//        var i = 0
//        text.enumerateLines { (line, _) in
//            let array = line.components(separatedBy: ",")
//
//            if let id = Int(array[0]),
//                let imdbID = Int(array[1]),
//                let tmdbID = Int(array[2]) {
//                self.getImageLinkWith(tmdbID, completion: { (posterPath) in
//                    self.movieLinks.append([String(id), String(imdbID), String(tmdbID), posterPath])
//                    i += 1
//                    if i == 9125 {
//                        completion()
//                    }
//                })
//
//                            getFeaturesForBookWith(grID) { (features) in
//                                tempGenre.append(contentsOf: features)
//                                bookGenres[id] = features
//                            }
//            }
//        }
//    }
    
}
