//
//  CategoriesTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 09/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class CategoriesTableViewCell: UITableViewCell {
    static let cellIdentifier = "CategoriesTableViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18.0)
        label.textAlignment = .center
        return label
    }()
        
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var type: Categories?
    var select: Bool = false {
        didSet {
            guard select else {
                titleLabel.backgroundColor = .clear
                titleLabel.textColor = .black
                return
            }
            
            titleLabel.backgroundColor = type?.color
            titleLabel.textColor = .white
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        
        addSubview(titleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
