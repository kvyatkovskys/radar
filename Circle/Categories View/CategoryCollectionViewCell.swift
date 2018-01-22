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
            make.top.equalToSuperview().offset(7.0)
            make.bottom.equalToSuperview().offset(-7.0)
            make.left.right.equalToSuperview().inset(2.0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(5.0)
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
