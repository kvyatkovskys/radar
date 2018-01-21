//
//  WorkDaysCollectionViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 21/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class WorkDaysCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "WorkDaysCollectionViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14.0)
        return label
    }()
    
    fileprivate let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 11.0)
        return label
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview().inset(5.0)
            make.height.equalTo(15.0)
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.right.left.equalTo(titleLabel)
            make.bottom.equalToSuperview()
        }
    }
    
    var day: String? {
        didSet {
            titleLabel.text = day
        }
    }
    
    var hours: String? {
        didSet {
            valueLabel.text = hours
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
