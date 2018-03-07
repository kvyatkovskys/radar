//
//  WorkDaysViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 21/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class WorkDaysViewController: UIViewController {
    fileprivate var workDays: WorkDays?
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        layout.minimumLineSpacing = 3.0
        
        let collection = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        collectionView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    init(workDays: WorkDays?) {
        self.workDays = workDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        updateViewConstraints()
        
        collectionView.register(WorkDaysCollectionViewCell.self, forCellWithReuseIdentifier: WorkDaysCollectionViewCell.cellIdentifier)
        let indexPath = IndexPath(row: workDays?.currentDay.index ?? 0, section: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    func reloadedData(workDays: WorkDays?) {
        self.workDays = workDays
        collectionView.reloadData()
    }
}

extension WorkDaysViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return workDays?.opened.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let day = workDays?.opened[indexPath.row].day.title
        let hours = (workDays?.opened[indexPath.row].hour ?? "") + " - " + (workDays?.closed[indexPath.row].hour ?? "")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkDaysCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? WorkDaysCollectionViewCell ?? WorkDaysCollectionViewCell()
        
        cell.day = day
        cell.hours = hours
        cell.colorCurrentDay = nil
        
        if workDays?.currentDay.index == indexPath.row {
            cell.colorCurrentDay = workDays?.currentDay.color
        }
        
        return cell
    }
}

extension WorkDaysViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 95.0, height: 50.0)
    }
}
