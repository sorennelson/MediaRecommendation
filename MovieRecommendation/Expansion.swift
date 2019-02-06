//
//  Expansion.swift
//  MovieRecommendation
//
//  Created by Soren Nelson on 2/6/19.
//  Copyright © 2019 SORN. All rights reserved.
//

import Foundation

extension ViewController {
    
    enum Expansion {
        case notExpanded
        case recommendation
    }
    
    private func expand(to expandTo: Expansion) {
        
        switch expandTo {
        case .notExpanded:
            switch expansion {
            case .recommendation:
                minimize()
            default: break
            }
            
        case .recommendation:
            expand()
        }
        
        expansion = expandTo
    }
    
    private func minimize() {
        recToViewConstraint.isActive = false
        recToCategoriesConstraint.isActive = true
        
        ratingsToViewConstraint.isActive = false
        ratingsToCategoriesConstraint.isActive = true
        
        categoriesTableView.isHidden = false
    }
    
    private func expand() {
        recToCategoriesConstraint.isActive = false
        
        recToViewConstraint.constant = 66
        recToViewConstraint.isActive = true
        
        ratingsToViewConstraint.constant = 66
        ratingsToViewConstraint.isActive = true
        
        categoriesTableView.isHidden = true
    }
    
    @IBAction func recExpandButtonPressed(_ sender: Any) {
        if (expansion == .notExpanded) {
            expand(to: .recommendation)
        } else {
            expand(to: .notExpanded)
        }
    }
    
}
