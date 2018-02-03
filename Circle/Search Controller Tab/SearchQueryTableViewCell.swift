//
//  SearchQueryTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 03/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class SearchQueryTableViewCell: UITableViewCell {
    static let cellIdentifier = "SearchQueryTableViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
