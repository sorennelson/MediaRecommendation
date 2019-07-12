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
    
    func loadAllMedia(_ mediaType: MediaType, completion:@escaping (String) -> ()) {
        let requestString = API_HOST + (mediaType == .Movies ? "movies" : "books") + "/all"
        loadData(requestString: requestString) { (data, str) in
            guard let data = data else {
                completion(str)
                return
            }
            do {
                if mediaType == .Movies {
                    let movies = try JSONDecoder().decode([Movie].self, from: data)
                    ObjectController.sharedInstance.movies = movies
//                        .sorted { $0.title < $1.title }
                    completion(str)
                    
                } else {
                    let books = try JSONDecoder().decode([Book].self, from: data)
                    ObjectController.sharedInstance.books = books
//                        .sorted { $0.title < $1.title }
                    completion(str)
                }
            } catch let error {
                print(error)
                completion(error.localizedDescription)
            }
        }
    }
    
    private func loadData(requestString: String, completion:@escaping (Data?, String) -> ()) {
        Alamofire.request(requestString).responseData { (response) in
            switch response.result {
                
            case .success(let data):
                switch response.response?.statusCode ?? -1 {
                case 200:
                    completion(data, "Success")
                default:
                    completion(data, "Unexpected Error")
                }
                
            case .failure(let error):
                completion(nil, error.localizedDescription)
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
