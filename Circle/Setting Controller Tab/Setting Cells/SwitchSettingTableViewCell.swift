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
        image.contentMode = .center
        image.tintColor = .white
        image.layer.cornerRadius = 5.0
        return image
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0)
        label.numberOfLines = 0
        return label
    }()
    
    let switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.onTintColor = UIColor.mainColor
        return switchButton
    }()
    
    var img: UIImage? {
        didSet {
            imageCell.image = img
        }
    }
    
    var imageColor: UIColor? {
        didSet {
            imageCell.backgroundColor = imageColor
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var enable: Bool = false {
        didSet {
            switchButton.setOn(enable, animated: false)
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(imageCell)
        addSubview(titleLabel)
        addSubview(switchButton)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
