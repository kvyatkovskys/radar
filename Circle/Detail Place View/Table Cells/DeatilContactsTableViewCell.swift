//
//  DeatilContactsTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DeatilContactsTableViewCell: UITableViewCell {
    static let cellIdentifier = "DeatilContactsTableViewCell"

    fileprivate var collectionDataSource: ListContactsCollectionDataSource?
    //swiftlint:disable weak_delegate
    fileprivate var collectionDelegate: ListContactsCollectionDelegate?
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        
        let collection = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.showsHorizontalScrollIndicator = false
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
            collectionView.register(ListContactsCollectionViewCell.self, forCellWithReuseIdentifier: ListContactsCollectionViewCell.cellIdentifier)
            collectionDataSource = ListContactsCollectionDataSource(collectionView: collectionView, contacts.filter({ $0.value != nil }))
            collectionDelegate = ListContactsCollectionDelegate(collectionView: collectionView, contacts.filter({ $0.value != nil }))
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(collectionView)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
