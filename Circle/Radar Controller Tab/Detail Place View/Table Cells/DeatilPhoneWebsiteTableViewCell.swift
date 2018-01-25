//
//  DeatilPhoneWebsiteTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DeatilPhoneWebsiteTableViewCell: UITableViewCell {
    static let cellIdentifier = "DeatilPhoneWebsiteTableViewCell"

    fileprivate var collectionDataSource: ListItemsCollectionDataSource?
    //swiftlint:disable weak_delegate
    fileprivate var collectionDelegate: ListButtonsCollectionDelegate?
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.itemSize = CGSize(width: 100.0, height: 50.0)
        layout.sectionInset = UIEdgeInsets(top: 5.0, left: 2.0, bottom: 5.0, right: 2.0)
        
        let collection = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        return collection
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        collectionView.snp.remakeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    var contacts: [Contact] = [] {
        didSet {
            collectionView.register(ListItemCollectionViewCell.self, forCellWithReuseIdentifier: ListItemCollectionViewCell.cellIdentifier)
            collectionDataSource = ListItemsCollectionDataSource(collectionView: collectionView, contacts.filter({ $0.value != nil }))
            collectionDelegate = ListButtonsCollectionDelegate(collectionView: collectionView, contacts.filter({ $0.value != nil }))
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
