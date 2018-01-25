//
//  DetailSectionTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 19/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DetailSectionTableViewCell: UITableViewCell {
    static let cellIdentifier = "DetailSectionTableViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20.0)
        label.textColor = .black
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
            make.height.equalTo(25.0)
            make.left.equalToSuperview().offset(10.0)
            make.width.equalTo(200.0)
            make.bottom.equalToSuperview().offset(-5.0)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.white
        addSubview(titleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
