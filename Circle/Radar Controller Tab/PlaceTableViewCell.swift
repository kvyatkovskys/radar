//
//  PlaceTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 31/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit

final class PlaceTableViewCell: UITableViewCell {
    static let cellIndetifier = "PlaceTableViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(15.0)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        addSubview(titleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
