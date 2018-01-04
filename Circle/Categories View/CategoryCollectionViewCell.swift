//
//  CategoryCollectionViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 02/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "CategoryCollectionViewCell"
    
    fileprivate let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12.0)
        label.textAlignment = .center
        return label
    }()
    
    var color: UIColor? {
        didSet {
            mainView.backgroundColor = color
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        mainView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5.0)
            make.height.equalTo(20.0)
            make.left.right.equalToSuperview().inset(10.0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mainView)
        mainView.addSubview(titleLabel)
        
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
