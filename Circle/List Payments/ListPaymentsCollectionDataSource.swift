//
//  ListPaymentsCollectionDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 24/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListPaymentsCollectionDataSource: NSObject {
    fileprivate let payments: [PaymentType?]
    
    init(collectionView: UICollectionView, _ payments: [PaymentType?]) {
        self.payments = payments
        super.init()
        collectionView.dataSource = self
    }
}

extension ListPaymentsCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return payments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListItemCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? ListItemCollectionViewCell ?? ListItemCollectionViewCell()
        
        cell.payment = payments[indexPath.row]
        return cell
    }
}
