//
//  ListRServicesCollectionDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 27/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListRServicesCollectionDataSource: NSObject {
    fileprivate let services: [RestaurantServiceType?]
    
    init(collectionView: UICollectionView, _ services: [RestaurantServiceType?]) {
        self.services = services
        super.init()
        collectionView.dataSource = self
    }
}

extension ListRServicesCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListItemCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? ListItemCollectionViewCell ?? ListItemCollectionViewCell()
        
        cell.service = services[indexPath.row]
        return cell
    }
}
