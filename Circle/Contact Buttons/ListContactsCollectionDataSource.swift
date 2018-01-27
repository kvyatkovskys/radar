//
//  ListContactsCollectionDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 20/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListContactsCollectionDataSource: NSObject {
    fileprivate let buttons: [Contact]
    
    init(collectionView: UICollectionView, _ buttons: [Contact]) {
        self.buttons = buttons
        super.init()
        collectionView.dataSource = self
    }
}

extension ListContactsCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListContactsCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? ListContactsCollectionViewCell ?? ListContactsCollectionViewCell()
        cell.contact = buttons[indexPath.row]
        return cell
    }
}
