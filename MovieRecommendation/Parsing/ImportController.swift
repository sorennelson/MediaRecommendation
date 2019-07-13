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
    
    
    /// Loads all media of the given type.
    ///
    /// - Parameters:
    ///   - mediaType: MediaType.
    ///   - completion: (success bool, error description)
    func loadAllMedia(_ mediaType: MediaType, completion:@escaping (Bool, String) -> ()) {
        
        let requestString = API_HOST + (mediaType == .Movies ? "movies" : "books") + "/all"
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
        let requestString = API_HOST + (mediaType == .Movies ? "movies" : "books") + "/all/get_top_recommendations"
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
