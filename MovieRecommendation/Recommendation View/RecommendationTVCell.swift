//
//  RecommendationTVCell.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/19/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class RecommendationTableViewCell : NSTableCellView {
    
    @IBOutlet var collectionView: NSCollectionView!
    var collectionViewDataSource = RecommendationCollectionView()
    
    override func awakeFromNib() {
        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = collectionViewDataSource
        collectionView.reloadData()
    }
    
    func reloadCollectionView() {
        collectionView.reloadData()
    }
}
