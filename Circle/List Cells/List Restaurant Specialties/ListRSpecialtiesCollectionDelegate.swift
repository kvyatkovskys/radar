//
//  ListRSpecialtiesCollectionDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 28/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListRSpecialtiesCollectionDelegate: NSObject {
    fileprivate let specialties: [RestaurantSpecialityType?]
    
    init(collectionView: UICollectionView, _ restaurantSpeciality: RestaurantSpeciality?) {
        self.specialties = restaurantSpeciality?.specialties ?? []
        super.init()
        collectionView.delegate = self
    }
}

extension ListRSpecialtiesCollectionDelegate: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: specialties[indexPath.row]?.width ?? 70.0, height: 44.0)
    }
}
