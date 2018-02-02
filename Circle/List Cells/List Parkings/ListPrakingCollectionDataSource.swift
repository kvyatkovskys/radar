//
//  ListPrakingCollectionDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 26/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListPrakingCollectionDataSource: NSObject {
    fileprivate let parkings: [ParkingType?]
    
    init(collectionView: UICollectionView, _ parkings: [ParkingType?]) {
        self.parkings = parkings
        super.init()
        collectionView.dataSource = self
    }
}

extension ListPrakingCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parkings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListItemCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? ListItemCollectionViewCell ?? ListItemCollectionViewCell()
        
        cell.parking = parkings[indexPath.row]
        return cell
    }
}
