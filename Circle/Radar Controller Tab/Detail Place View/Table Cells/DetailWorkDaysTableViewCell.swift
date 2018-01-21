//
//  DetailWorkDaysTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 21/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DetailWorkDaysTableViewCell: UITableViewCell, UICollectionViewDelegate {
    static let cellIdentifier = "DetailWorkDaysTableViewCell"
    
    fileprivate var collectionDataSource: WorkDaysCollectionDataSource?
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.itemSize = CGSize(width: 90.0, height: 50.0)
        layout.sectionInset = UIEdgeInsets(top: 5.0, left: 0, bottom: 5.0, right: 0)
        
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
    
    var workDays: WorkDays? {
        didSet {
            if let days = workDays {
                collectionView.register(WorkDaysCollectionViewCell.self, forCellWithReuseIdentifier: WorkDaysCollectionViewCell.cellIdentifier)
                collectionDataSource = WorkDaysCollectionDataSource(collectionView: collectionView, days)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(collectionView)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
