//
//  ListRSpecialtiesCollectionDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 28/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListRSpecialtiesCollectionDataSource: NSObject {
    fileprivate let specialties: [RestaurantSpecialityType?]
    fileprivate let color: UIColor?
    
    init(collectionView: UICollectionView, _ restaurantSpeciality: RestaurantSpeciality?) {
        self.specialties = restaurantSpeciality?.specialties ?? []
        self.color = restaurantSpeciality?.color
        super.init()
        collectionView.dataSource = self
    }
}

extension ListRSpecialtiesCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return specialties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListRSpecialityCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? ListRSpecialityCollectionViewCell ?? ListRSpecialityCollectionViewCell()
        
        cell.speciality = specialties[indexPath.row]
        cell.color = color
        return cell
    }
}
