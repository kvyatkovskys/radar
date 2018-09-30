//
//  PlaceHeaderTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 03/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class PlaceHeaderTableViewCell: UITableViewCell {
    static let cellIdentifier = "PlaceHeaderTableViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 10.0
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 15.0)
        label.textColor = .white
        return label
    }()
    
    var color: UIColor? {
        didSet {
            titleLabel.backgroundColor = color
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5.0)
            make.centerX.equalToSuperview()
            make.width.equalTo(80.0)
            make.height.equalTo(25.0)
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
