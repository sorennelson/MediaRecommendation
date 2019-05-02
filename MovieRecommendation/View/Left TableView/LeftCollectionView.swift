//
//  LeftCollectionView.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 12/18/18.
//  Copyright © 2018 SORN. All rights reserved.
//

import Foundation
import Cocoa

class LeftCollectionView : NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = ObjectController.sharedInstance.getAllMediaCount()
        if count == 0 { return 3 }
        else { return count }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
//        let imageFile = imageDirectoryLoader.imageFileForIndexPath(indexPath)
//        collectionViewItem.imageFile = imageFile
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RecommendationCVCell"), for: indexPath)
        guard let collectionViewItem = item as? LeftTVMediaCVCell else {return item}
        
        collectionViewItem.media = ObjectController.sharedInstance.getAllMedia(for: indexPath.item)
        
        return collectionViewItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 175, height: 260)
    }
    
    
    
}
