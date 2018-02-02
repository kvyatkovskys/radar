//
//  ListRServicesCollectionDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 28/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListRServicesCollectionDelegate: NSObject {
    fileprivate let services: [RestaurantServiceType?]
    
    init(collectionView: UICollectionView, _ restaurantService: RestaurantService?) {
        self.services = restaurantService?.services ?? []
        super.init()
        collectionView.delegate = self
    }
}

extension ListRServicesCollectionDelegate: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: services[indexPath.row]?.width ?? 70.0, height: 44.0)
    }
}
