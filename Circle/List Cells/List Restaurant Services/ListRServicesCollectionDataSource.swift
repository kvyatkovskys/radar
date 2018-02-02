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
    fileprivate let color: UIColor?
    
    init(collectionView: UICollectionView, _ restaurantService: RestaurantService?) {
        self.services = restaurantService?.services ?? []
        self.color = restaurantService?.color
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListRServiceCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? ListRServiceCollectionViewCell ?? ListRServiceCollectionViewCell()
        
        cell.service = services[indexPath.row]
        cell.color = color
        return cell
    }
}
