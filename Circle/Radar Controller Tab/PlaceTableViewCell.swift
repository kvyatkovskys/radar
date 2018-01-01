//
//  PlaceTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 31/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit

fileprivate extension UIColor {
    static var shadowGray: UIColor {
        return UIColor(withHex: 0xecf0f1, alpha: 1.0)
    }
}

final class PlaceTableViewCell: UITableViewCell {
    static let cellIndetifier = "PlaceTableViewCell"
    
    fileprivate let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
        view.layer.shadowRadius = 8.0
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        return view
    }()
    
    let imageCell: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .shadowGray
        return image
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        mainView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview().inset(10.0)
        }
        
        imageCell.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(10.0)
            make.size.equalTo(CGSize(width: 100.0, height: 130.0))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageCell.snp.right).offset(10.0)
            make.top.right.equalToSuperview().inset(10.0)
            make.height.greaterThanOrEqualTo(60.0)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        addSubview(mainView)
        mainView.addSubview(imageCell)
        mainView.addSubview(titleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
