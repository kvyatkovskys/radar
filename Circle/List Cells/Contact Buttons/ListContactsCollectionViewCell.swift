//
//  ListContactsCollectionViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 27/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

fileprivate extension UIColor {
    static var shadowGray: UIColor {
        return UIColor(withHex: 0xecf0f1, alpha: 0.7)
    }
    
    static var mainColor: UIColor {
        return UIColor(withHex: 0xf82462, alpha: 1.0)
    }
}

final class ListContactsCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "ListContactsCollectionViewCell"
    
    fileprivate let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.shadowGray
        view.layer.cornerRadius = 5.0
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14.0)
        label.textColor = UIColor.mainColor
        label.textAlignment = .center
        return label
    }()
    
    fileprivate let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.tintColor = UIColor.mainColor
        return image
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        mainView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(30.0)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(titleLabel.snp.left).offset(-5.0)
            make.size.equalTo(CGSize(width: 20.0, height: 20.0))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(10.0)
            make.height.equalTo(15.0)
        }
    }
    
    var contact: Contact? {
        didSet {
            imageView.image = contact?.type.image
            titleLabel.text = contact?.type.title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mainView)
        mainView.addSubview(imageView)
        mainView.addSubview(titleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
