//
//  ListFavoritesNoticeTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 09/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListFavoritesNoticeTableViewCell: UITableViewCell {
    static let cellIdentifier = "ListFavoritesNoticeTableViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(5.0)
            make.right.equalToSuperview()
            make.left.equalToSuperview().offset(15.0)
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(titleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
