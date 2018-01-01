//
//  CategoriesViewDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 02/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class CategoriesViewDelegate: NSObject {
    init(_ collectionView: UICollectionView) {
        super.init()
        collectionView.delegate = self
    }
}

extension CategoriesViewDelegate: UICollectionViewDelegate {
    
}
