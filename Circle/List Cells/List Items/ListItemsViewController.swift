//
//  ListItemsViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 24/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListItemsViewController: UIViewController {
    fileprivate var payments: [PaymentType?]
    fileprivate var parkings: [ParkingType?]
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0)
        layout.minimumLineSpacing = 5.0
        
        let collection = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        collectionView.snp.remakeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    init(payments: [PaymentType?], parkings: [ParkingType?]) {
        self.payments = payments
        self.parkings = parkings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        updateViewConstraints()
        collectionView.register(ListItemCollectionViewCell.self, forCellWithReuseIdentifier: ListItemCollectionViewCell.cellIdentifier)
    }
    
    func reloadedData(payments: [PaymentType?], parkings: [ParkingType?]) {
        self.payments = payments
        self.parkings = parkings
        collectionView.reloadData()
    }
}

extension ListItemsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return payments.isEmpty ? parkings.count : payments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListItemCollectionViewCell.cellIdentifier,
                                                      for: indexPath) as? ListItemCollectionViewCell ?? ListItemCollectionViewCell()
        
        guard payments.isEmpty else {
            cell.payment = payments[indexPath.row]
            return cell
        }
        
        cell.parking = parkings[indexPath.row]
        return cell
    }
}

extension ListItemsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard payments.isEmpty else {
            return CGSize(width: payments[indexPath.row]?.width ?? 80.0, height: 44.0)
        }
        return CGSize(width: parkings[indexPath.row]?.width ?? 80.0, height: 44.0)
    }
}
