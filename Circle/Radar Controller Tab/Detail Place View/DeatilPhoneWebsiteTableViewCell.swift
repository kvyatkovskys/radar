//
//  DeatilPhoneWebsiteTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DeatilPhoneWebsiteTableViewCell: UITableViewCell {
    static let cellIdentifier = "DeatilPhoneWebsiteTableViewCell"
    
    fileprivate let phoneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Call", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    fileprivate let websiteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Open website", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        phoneButton.snp.makeConstraints { (make) in
            make.width.equalTo(100.0)
            make.top.bottom.equalToSuperview().inset(10.0)
            make.right.equalTo(self.snp.centerX).offset(-60.0)
        }
        
        websiteButton.snp.makeConstraints { (make) in
            make.width.equalTo(100.0)
            make.top.bottom.equalToSuperview().inset(10.0)
            make.left.equalTo(self.snp.centerX).offset(60.0)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(phoneButton)
        addSubview(websiteButton)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
