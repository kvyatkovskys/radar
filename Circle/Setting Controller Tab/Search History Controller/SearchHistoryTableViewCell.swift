//
//  SearchHistoryTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 05/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class SearchHistoryTableViewCell: UITableViewCell {
    static let cellIdentifier = "SearchHistoryTableViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    fileprivate let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0)
        label.textColor = .gray
        return label
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(2.0)
            make.right.equalToSuperview()
            make.left.equalToSuperview().offset(15.0)
            make.height.equalTo(20.0)
        }
        
        subTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalTo(titleLabel)
            make.bottom.equalToSuperview()
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var subTitle: String? {
        didSet {
            subTitleLabel.text = subTitle
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
