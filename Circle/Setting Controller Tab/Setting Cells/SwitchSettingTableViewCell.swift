//
//  SwitchSettingTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 07/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class SwitchSettingTableViewCell: UITableViewCell {
    static let cellIdentifier = "SwitchSettingTableViewCell"
    
    fileprivate let imageCell: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0)
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate let switchButton: UISwitch = {
        let switchButton = UISwitch()
        return switchButton
    }()
    
    var img: UIImage? {
        didSet {
            imageCell.image = img
        }
    }
    
    var imageColor: UIColor? {
        didSet {
            imageCell.tintColor = imageColor
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        imageCell.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 25.0, height: 25.0))
            make.left.equalToSuperview().offset(15.0)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageCell.snp.right).offset(10.0)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(switchButton.snp.left).offset(-10.0)
        }
        
        switchButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15.0)
            make.width.equalTo(51.0)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(imageCell)
        addSubview(titleLabel)
        addSubview(switchButton)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
