//
//  WorkDaysCollectionDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 21/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class WorkDaysCollectionDataSource: NSObject {
    fileprivate let workDays: WorkDays
    
    init(collectionView: UICollectionView, _ workDays: WorkDays) {
        self.workDays = workDays
        super.init()
        collectionView.dataSource = self
    }
}

extension WorkDaysCollectionDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return workDays.opened.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let day = workDays.opened[indexPath.row].day.rawValue
        let hours = workDays.opened[indexPath.row].hour + " - " + workDays.closed[indexPath.row].hour
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkDaysCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? WorkDaysCollectionViewCell ?? WorkDaysCollectionViewCell()
        
        cell.day = day
        cell.hours = hours
        return cell
    }
}
