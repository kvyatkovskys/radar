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
        
        let indexPath = IndexPath(row: workDays.currentDay.index ?? 0, section: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
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
        cell.colorCurrentDay = nil
        
        if workDays.currentDay.index == indexPath.row {
            cell.colorCurrentDay = workDays.currentDay.color
        }
        
        return cell
    }
}
