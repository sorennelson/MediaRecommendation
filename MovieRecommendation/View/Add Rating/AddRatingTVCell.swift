//
//  AddRatingTVCell.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 4/20/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation
import Cocoa

class AddRatingTVCell: NSTableCellView {
    
    @IBOutlet var mediaImage: NSImageView!
    @IBOutlet var title: NSTextField!
    @IBOutlet var yearAndType: NSTextField!
    @IBOutlet var genres: NSTextField!
    @IBOutlet var rating: NSTextField!
    
    var media: Media? {
        didSet {
            if media is Movie {
                setMovie(media as! Movie)
                
            } else if media is Book {
                let book = media as! Book
                title.stringValue = book.title
                for i in 0..<book.genres.count-1 {
                    genres.stringValue += book.genres[i] + ", "
                }
                genres.stringValue += book.genres[book.genres.count - 1]
                if let year = book.year { yearAndType.stringValue = year + "| Book" }
                else { yearAndType.stringValue = "Book" }
            }
        }
    }
        
    func setMovie(_ movie: Movie) {
        movie.getImageData(completion: { (data) in
            if let data = data {
                DispatchQueue.main.async {
                    self.mediaImage.image = NSImage(data: data)
                }
            }
        })
        self.title.stringValue = movie.title
        for i in 0..<movie.genres.count-1 {
            self.genres.stringValue += movie.genres[i] + ", "
        }
        self.genres.stringValue += movie.genres[movie.genres.count - 1]
        self.yearAndType.stringValue = "Movie"
    }
    
    @IBAction func upRating(_ sender: Any) {
    }
    
    @IBAction func downRating(_ sender: Any) {
    }
    
    
}