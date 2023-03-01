//
//  UserController.swift
//  MediaRecommendation
//
//  Created by Soren Nelson on 6/23/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Alamofire

class UserController {
    
    static var sharedInstance = UserController()
    
    // MARK: LOGIN/OUT
    
    /// Creates an account for a new User.
    ///
    /// - Parameters:
    ///   - email: String. A valid email address.
    ///   - password: String. A valid password
    ///   - completion: (success signing up bool, error string?)
    func createUser(username:String, password:String, completion: @escaping (Bool, String?) -> ()) {
        let params = ["username": username, "password": password] as [String:Any]
        Alamofire.request(API_HOST + "signup/", method: .post, parameters: params).responseData { response in
            switch response.result {
            case .success(let data):
    
                switch response.response?.statusCode ?? -1 {
                case 200:
                    UserDefaults.standard.setValue(username, forKey: "username")
                    UserDefaults.standard.setValue(password, forKey: "password")
                    
                    if let error = self.didLogin(userData: data) {
                        print("ERROR SIGNING UP: " + error)
                        completion(false, "Internal Error")
                    } else {
                        completion(true, nil)
                    }
                    
                case 403:
                    completion(false, "That email is already in use")
                default:
                    completion(false, "Unexpected Error")
                }
                
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    
    /// Logs the user in on the server.
    ///
    /// - Parameters:
    ///   - email: String. the User's email used when they signed up
    ///   - password: String. the User's password used when they signed up
    ///   - completion: (success logging in bool, error string?)
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> ()) {
        let params = ["username": username, "password": password] as [String:Any]
        Alamofire.request(API_HOST + "login/", method: .post, parameters: params).responseData{ response in
            switch response.result {
            case .success(let data):
                
                switch response.response?.statusCode ?? -1 {
                case 200:
                    UserDefaults.standard.setValue(username, forKey: "username")
                    UserDefaults.standard.setValue(password, forKey: "password")
                    
                    if let error = self.didLogin(userData: data) {
                        print("ERROR LOGGING IN: " + error)
                        completion(false, "Internal Error")
                    } else {
                        completion(true, nil)
                    }
                    
                case 401:
                    completion(false, "Username or Password Incorrect")
                default:
                    completion(false, "Unexpected Error")
                }
                
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    /// Checks whether the User already is logged in on the server.
    ///
    /// - Parameter completion: (error string?, is logged in bool, user data?)
    func attemptLogin(completion:@escaping (Bool) -> ()) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let password = UserDefaults.standard.string(forKey: "password") else {
            completion(false)
            return
        }
        let params = ["username": username, "password": password] as [String:Any]
        Alamofire.request(API_HOST+"login/", method:.post, parameters:params).responseData { response in
            switch response.result {
            case .success(let data):
                if response.response?.statusCode == 200 {
                    print("LOGGED IN")
                    
                    if let error = self.didLogin(userData: data) {
                        completion(false)
                    } else {
                        completion(true)
                    }

                } else {
                    completion(false)
                }
                
            case .failure(let error):
                print("ERROR LOGGING IN: " + error.localizedDescription)
                completion(false)
            }
        }
        
    }
    
    /// Call when the User is logged in on the server to decode the JSON User data into the current User.
    ///
    /// - Parameter userData: the JSON User data from the server
    /// - Returns: error string?. if no error string the User was successfully decoded.
    func didLogin(userData: Data) -> String? {
        do {
            User.current = try JSONDecoder().decode(User.self, from: userData)
            return nil
        } catch {
            return error.localizedDescription
        }
    }
    
    func logout() {
        User.current = nil
        UserDefaults.standard.setValue(nil, forKey: "username")
        UserDefaults.standard.setValue(nil, forKey: "password")
        Alamofire.request(API_HOST+"logout/")
    }
    
    
// MARK: RATINGS
    func getMediaAndRating(for index:Int) -> (Media, Double)? {
        var media:Media
        var rating:Double
        if ObjectController.currentMediaType == .Books {
            guard let bookRatings = User.current?.bookRatings else { return nil }
            media = bookRatings[index].book
            rating = Double(bookRatings[index].rating)
        } else {
            guard let movieRatings = User.current?.movieRatings else { return nil }
            media = movieRatings[index].movie
            rating = Double(movieRatings[index].rating)
        }
        return (media, rating)
    }
    
    func getRatingsCount() -> Int {
        if ObjectController.currentMediaType == .Books {
            guard let bookRatings = User.current?.bookRatings else { return 0 }
            return bookRatings.count
        } else {
            guard let movieRatings = User.current?.movieRatings else { return 0 }
            return movieRatings.count
        }
    }
    
}
