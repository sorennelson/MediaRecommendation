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
    
    func createUser(email:String, password:String, completion: @escaping (Bool, String?) -> ()) {
        let params = ["username":email,"password":password] as [String:Any]
        Alamofire.request(API_HOST+"auth/signup",method:.post,parameters:params).responseData
            { response in switch response.result {
            case .success(let data):
                switch response.response?.statusCode ?? -1 {
                case 200:
                    self.decodeUserFrom(userData: data, completion: { (success, error) in
                        completion(success, error)
                    })
                case 401:
                    completion(false, "That email is already in use")
                default:
                    completion(false, "Unexpected Error")
                }
            case .failure(let error):
                completion(false, error.localizedDescription)
                }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> ()) {
        let params = ["username":email,"password":password] as [String:Any]
        Alamofire.request(API_HOST+"auth/login",method:.post,parameters:params).responseData
            { response in switch response.result {
                
            case .success(let data):
                switch response.response?.statusCode ?? -1 {
                case 200:
                    self.decodeUserFrom(userData: data, completion: { (success, error) in
                        //                        if let user = User.current {
                        //                            UserDefaults.standard.setValue(user.id, forKey: "user")
                        //                        }
                        completion(success, error)
                    })
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
    
    func decodeUserFrom(userData: Data, completion: @escaping (Bool, String?) -> ()) {
        do {
            //decode data into user object
            User.current = try JSONDecoder().decode(User.self, from: userData)
            completion(true, nil)
        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    func logout() {
        User.current = nil
        //        SocketController.sharedInstance.sock.disconnect()
        UserDefaults.standard.setValue(nil, forKey: "user")
        //        Alamofire.reques
        Alamofire.request(API_HOST+"auth/logout")
    }
    
}

//    private func createUser(authResult: AuthDataResult, completion:@escaping (Bool) -> ()) {
//        self.currentUser = User(firID: authResult.user.uid,
//                                ubid: bookUsers.count, numBooks: books.count,
//                                umid: movieUsers.count, numMovies: movies.count)
//        self.bookUsers.append(currentUser!.bookRatingUser!)
//        self.movieUsers.append(currentUser!.movieRatingUser!)
//
//        for movie in movies {
//            movie.value.ratings.append(0)
//        }
//        for book in books {
//            book.value.ratings.append(0)
//        }
//
//        if let _ = bookRM {
//            let averages = getBookAverages()
//            bookRM!.addUser(averages: averages)
//            // TODO: run
//        }
//
//        if let _ = movieRM {
//            let averages = getMovieAverages()
//            movieRM!.addUser(averages: averages)
//            // TODO: run
//        }
//        completion(true)
//
////      TODO: Save User to database
//
//
//    }
