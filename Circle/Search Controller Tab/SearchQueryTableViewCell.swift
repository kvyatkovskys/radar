//
//  SearchQueryTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 03/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

fileprivate extension UIColor {
    static var blueTitle: UIColor {
        return UIColor(withHex: 0x4B98C8, alpha: 1.0)
    }
}

final class SearchQueryTableViewCell: UITableViewCell {
    static let cellIdentifier = "SearchQueryTableViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blueTitle
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 16.0)
        return label
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(15.0)
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
