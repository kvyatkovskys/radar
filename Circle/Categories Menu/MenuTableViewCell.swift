//
//  MenuTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 01.06.17.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit

private extension UIColor {
    static var selectMenu: UIColor {
        return UIColor(withHex: 0x161b20, alpha: 1)
    }
}

final class MenuTableViewCell: UITableViewCell {
    static let cellIdentifier = "MenuTableViewCell"
    
    fileprivate let titleCell: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.textAlignment = .center
        return label
    }()
    
    override func updateConstraints() {
        titleCell.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }

        super.updateConstraints()
    }
    
    var title: String? {
        didSet {
            titleCell.text = title
        }
    }
    
    var select: Bool = false {
        didSet {
           
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        addSubview(titleCell)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
