//
//  ListRestaurantCollectionViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 28/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListRestaurantCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "ListRestaurantCollectionViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 12.0)
        label.textColor = .white
        label.layer.cornerRadius = 10.0
        label.layer.masksToBounds = true
        return label
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(25.0)
            make.left.right.equalToSuperview()
        }
    }
    
    var speciality: RestaurantSpecialityType? {
        didSet {
            titleLabel.text = speciality?.title
        }
    }
    
    var service: RestaurantServiceType? {
        didSet {
            titleLabel.text = service?.title
        }
    }
    
    var color: UIColor? {
        didSet {
            titleLabel.backgroundColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
