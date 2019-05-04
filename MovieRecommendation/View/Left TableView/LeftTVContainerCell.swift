//
//  LeftTVContainerCell.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/19/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class LeftTVContainerCell : NSTableCellView {
    
    @IBOutlet var collectionView: NSCollectionView!
    var collectionViewDataSource = LeftCollectionView()
    
    override func awakeFromNib() {
        
//        if #available(OSX 10.13, *) {
//            if let contentSize = self.collectionView.collectionViewLayout?.collectionViewContentSize {
//                self.collectionView.setFrameSize(contentSize)
//            }
//        }
        
        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = collectionViewDataSource
        collectionView.enclosingScrollView?.backgroundColor = NSColor.clear
        collectionView.backgroundColors = [NSColor.clear]
        collectionView.reloadData()
    }
    
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
}
