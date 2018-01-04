//
//  CategoriesViewDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 02/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class CategoriesViewDataSource: NSObject {
    var categories: [Categories]
    
    init(_ collectionView: UICollectionView, _ items: [Categories]) {
        self.categories = items
        super.init()
        collectionView.dataSource = self
    }
}

extension CategoriesViewDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? CategoryCollectionViewCell ?? CategoryCollectionViewCell()
        
        cell.color = categories[indexPath.row].color
        cell.title = categories[indexPath.row].title
        
        return cell
    }
}
