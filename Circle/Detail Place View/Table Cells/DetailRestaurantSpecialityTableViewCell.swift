//
//  DetailRestaurantSpecialityTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 28/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

typealias RestaurantSpeciality = (specialties: [RestaurantSpecialityType?], color: UIColor?)

final class DetailRestaurantSpecialityTableViewCell: UITableViewCell, UICollectionViewDelegate {
    static let cellIdentifier = "DetailRestaurantSpecialityTableViewCell"
    
    fileprivate var collectionDataSource: ListRSpecialtiesCollectionDataSource?
    //swiftlint:disable weak_delegate
    fileprivate var collectionDelegate: ListRSpecialtiesCollectionDelegate?
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0)
        
        let collection = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.delegate = self
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        collectionView.snp.remakeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    var restaurantSpeciatity: RestaurantSpeciality? {
        didSet {
            collectionView.register(ListRSpecialityCollectionViewCell.self,
                                    forCellWithReuseIdentifier: ListRSpecialityCollectionViewCell.cellIdentifier)
            collectionDataSource = ListRSpecialtiesCollectionDataSource(collectionView: collectionView, restaurantSpeciatity)
            collectionDelegate = ListRSpecialtiesCollectionDelegate(collectionView: collectionView, restaurantSpeciatity)
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
