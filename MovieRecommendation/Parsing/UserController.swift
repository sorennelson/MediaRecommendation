//
//  UserController.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 6/23/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Alamofire

class UserController {
    
    static var sharedInstance = UserController()
    
    
    /// Creates an account for a new User.
    ///
    /// - Parameters:
    ///   - email: String. A valid email address.
    ///   - password: String. A valid password
    ///   - completion: (success signing up bool, error string?, user data?)
    func createUser(username:String, password:String, completion: @escaping (Bool, String?, Data?) -> ()) {
        let params = ["username": username, "password": password] as [String:Any]
        Alamofire.request(API_HOST + "signup/", method: .post, parameters: params).responseData { response in
            switch response.result {
            case .success(let data):
    
                switch response.response?.statusCode ?? -1 {
                case 200:
                    UserDefaults.standard.setValue(username, forKey: "username")
                    UserDefaults.standard.setValue(password, forKey: "password")
                    completion(true, nil, data)
                case 403:
                    completion(false, "That email is already in use", data)
                default:
                    completion(false, "Unexpected Error", data)
                }
                
            case .failure(let error):
                completion(false, error.localizedDescription, nil)
            }
        }
    }
    
    
    /// Logs the user in on the server.
    ///
    /// - Parameters:
    ///   - email: String. the User's email used when they signed up
    ///   - password: String. the User's password used when they signed up
    ///   - completion: (success logging in bool, error string?, user data?)
    func login(username: String, password: String, completion: @escaping (Bool, String?, Data?) -> ()) {
        let params = ["username": username, "password": password] as [String:Any]
        Alamofire.request(API_HOST + "login/", method: .post, parameters: params).responseData{ response in
            switch response.result {
            case .success(let data):
                
                switch response.response?.statusCode ?? -1 {
                case 200:
                    UserDefaults.standard.setValue(username, forKey: "username")
                    UserDefaults.standard.setValue(password, forKey: "password")
                    completion(true, nil, data)
                case 401:
                    completion(false, "Username or Password Incorrect", data)
                default:
                    completion(false, "Unexpected Error", data)
                }
                
            case .failure(let error):
                completion(false, error.localizedDescription, nil)
            }
        }
    }
    
    /// Checks whether the User already is logged in on the server.
    ///
    /// - Parameter completion: (error string?, is logged in bool, user data?)
    func attemptLogin(completion:@escaping (String?, Bool, Data?) -> ()) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let password = UserDefaults.standard.string(forKey: "password") else {
            completion("Not Logged In", false, nil)
            return
        }
        let params = ["username": username, "password": password] as [String:Any]
        Alamofire.request(API_HOST+"login/", method:.post, parameters:params).responseData { response in
            switch response.result {
            case .success(let data):
                if response.response?.statusCode == 200 {
                    print("LOGGED IN")
                    completion(nil, true, data)
                    
                } else {
                    print("Not Logged In")
                    completion(nil, false, data)
                }
                
            case .failure(let error):
                print("ERROR LOGGING IN: " + error.localizedDescription)
                completion(error.localizedDescription, false, nil)
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
//            print(String(error))
            return error.localizedDescription
        }
    }
    
    func logout() {
        User.current = nil
        UserDefaults.standard.setValue(nil, forKey: "username")
        UserDefaults.standard.setValue(nil, forKey: "password")
        Alamofire.request(API_HOST+"logout/")
    }
    
}
