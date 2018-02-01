//
//  DetailRestaurantServiceTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 26/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

typealias RestaurantService = (services: [RestaurantServiceType?], color: UIColor?)

final class DetailRestaurantServiceTableViewCell: UITableViewCell, UICollectionViewDelegate {
    static let cellIdentifier = "DetailRestaurantServiceTableViewCell"
    
    fileprivate var collectionDataSource: ListRServicesCollectionDataSource?
    //swiftlint:disable weak_delegate
    fileprivate var collectionDelegate: ListRServicesCollectionDelegate?
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0)
        
        let collection = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.delegate = self
        return collection
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        collectionView.snp.remakeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    var restaurantService: RestaurantService? {
        didSet {
            collectionView.register(ListRServiceCollectionViewCell.self, forCellWithReuseIdentifier: ListRServiceCollectionViewCell.cellIdentifier)
            collectionDataSource = ListRServicesCollectionDataSource(collectionView: collectionView, restaurantService)
            collectionDelegate = ListRServicesCollectionDelegate(collectionView: collectionView, restaurantService)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
