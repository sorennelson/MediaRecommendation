//
//  BookParser.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 4/14/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

class BookParser {
    
    static let sharedInstance = BookParser()
    private let objectController = ObjectController.sharedInstance
    
    func importAndParseBooks() {
        guard let text = ParseController.sharedInstance.importFileAt("goodbooks-10k/books", ofType: "csv") else { return }
        parseBookDetails(text)
        
        guard let ratingText = ParseController.sharedInstance.importFileAt("goodbooks-10k/ratings", ofType: "csv") else { return }
        parseBookRatings(ratingText)
    }
    
//    private func parseBooks(_ text: String, genresText: String) {
//        self.parseBookGenres(genresText)
//        self.objectController.allBookGenres = Array(Set(self.objectController.allBookGenres))
//
//        let emptyValues: [[Int]] = Array(repeating: [], count: self.objectController.allBookGenres.count)
//        self.objectController.genreBooks = Dictionary(uniqueKeysWithValues: zip(self.objectController.allBookGenres, emptyValues))
//
//        self.parseBookDetails(text)
//    }
    
//    private func parseBookGenres(_ genresText: String) {
//        genresText.enumerateLines { (line, _) in
//            let bookArray = line.components(separatedBy: ",")
//
//            if let id = Int(bookArray[0]) {
//                var genres = [String]()
//
//                for i in 1..<bookArray.count {
//                    if !bookArray[i].isEmpty && bookArray[i] != " " {
//                        genres.append(bookArray[i])
//                        self.objectController.allBookGenres.append(bookArray[i])
//                    }
//                }
//                self.objectController.bookGenres[id] = genres
//            }
//        }
//    }
    
    private func parseBookDetails(_ text: String) {        
        text.enumerateLines { (line, _) in
            let bookArray = line.components(separatedBy: ",")
            
            if let id = Int(bookArray[0]),
                let grID = Int(bookArray[2]) {
                
                let author = bookArray[4]
                var year: String? = nil
                var titleIndex = 5
                if let _ = Int(bookArray[5]) {
                    year = bookArray[5]
                    titleIndex = 6
                }
                
                let title = bookArray[titleIndex]
                let grAvgRating = bookArray[titleIndex+1]
                let imgURL = bookArray[titleIndex+10]
                
                var genres = [String]()
                let genresRange = titleIndex+12...titleIndex+15
                for i in genresRange {
                    if bookArray.count > i {
                        let genre = bookArray[i]
                        genres.append(genre)
                        if let _ = self.objectController.genreBooks[genre] { self.objectController.genreBooks[genre]!.append(id) }
                        else { self.objectController.genreBooks[genre] = [id] }
                    }
                    else { break }
                }

                self.objectController.books[id] = Book(id: id, goodreadsID: grID, title: title, author: author, year: year, genres: genres, allBookGenres:Array(self.objectController.genreBooks.keys), avgRating: Double(grAvgRating) ?? 0, imageString: imgURL)
//                self.addBookToGenreBooks(id)
            }
        }
    }
    
    private func parseBookRatings(_ text: String) {
        for i in 0..<53425 {
            self.objectController.bookUsers.append(User(id: i, numMedia: 10000))
        }
        
        text.enumerateLines { (line, _) in
            let ratingArray = line.components(separatedBy: ",")
            
            if let uID = Int(ratingArray[0]),
                let bID = Int(ratingArray[1]) {
                let rating = Double(ratingArray[2]) ?? 0.0
                
                self.objectController.bookUsers[uID].addRating(rating, for: bID)
                self.objectController.books[bID]?.addRating(rating, for: uID)
            }
        }
    }
    
    
    
    
}
