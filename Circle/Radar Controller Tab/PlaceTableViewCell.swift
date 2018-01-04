//
//  PlaceTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 31/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate extension UIColor {
    static var shadowGray: UIColor {
        return UIColor(withHex: 0xecf0f1, alpha: 1.0)
    }
}

final class PlaceTableViewCell: UITableViewCell {
    static let cellIndetifier = "PlaceTableViewCell"
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate var collectionDataSource: CategoriesViewDataSource?
    fileprivate weak var collectionDelegate: CategoriesViewDelegate?
    
    fileprivate let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
        view.layer.shadowRadius = 8.0
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        return view
    }()
    
    let imageCell: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .shadowGray
        image.layer.cornerRadius = 5.0
        return image
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17.0)
        return label
    }()
    
    fileprivate let aboutLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .gray
        label.font = .systemFont(ofSize: 13.0)
        return label
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 90.0, height: 20.0)
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 0.0
        
        let collection = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        
        return collection
    }()
    
    var categories: [Categories]? {
        didSet {
            guard (categories ?? []).count > 1 else { return }
            collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.cellIdentifier)
            collectionDataSource = CategoriesViewDataSource(collectionView, categories ?? [])
            collectionDelegate = CategoriesViewDelegate(collectionView)
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var about: String? {
        didSet {
            aboutLabel.text = about
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        mainView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview().inset(10.0)
        }
        
        imageCell.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(10.0)
            make.size.equalTo(CGSize(width: 100.0, height: 130.0))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageCell.snp.right).offset(10.0)
            make.top.equalToSuperview().offset(10.0)
            make.right.equalToSuperview().inset(10.0)
            make.height.lessThanOrEqualTo(50.0)
        }
        
        aboutLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5.0)
            make.left.right.equalTo(titleLabel)
            make.height.lessThanOrEqualTo(60.0)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.bottom.equalTo(mainView).offset(-10.0)
            make.left.equalTo(imageCell.snp.right).offset(10.0)
            make.right.equalTo(titleLabel)
            make.height.equalTo(30.0)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        addSubview(mainView)
        mainView.addSubview(imageCell)
        mainView.addSubview(titleLabel)
        mainView.addSubview(aboutLabel)
        mainView.addSubview(collectionView)
        
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
