//
//  FCButtonLoginTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 13/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class FCButtonLoginTableViewCell: UITableViewCell {
    static let cellIdentifier = "FCButtonLoginTableViewCell"
    
    fileprivate let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["public_profile", "email"]
        return button
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        loginButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(loginButton)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
