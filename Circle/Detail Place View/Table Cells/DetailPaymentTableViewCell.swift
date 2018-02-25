//
//  DetailPaymentTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 24/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DetailPaymentTableViewCell: UITableViewCell, UICollectionViewDelegate {
    static let cellIdentifier = "DetailPaymentTableViewCell"
    
    fileprivate var collectionDataSource: ListPaymentsCollectionDataSource?
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.itemSize = CGSize(width: 70.0, height: 44.0)
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
    
    var payments: [PaymentType?] = [] {
        didSet {
            collectionView.register(ListItemCollectionViewCell.self, forCellWithReuseIdentifier: ListItemCollectionViewCell.cellIdentifier)
            collectionDataSource = ListPaymentsCollectionDataSource(collectionView: collectionView, payments)
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
