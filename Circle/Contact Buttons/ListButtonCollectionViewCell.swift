//
//  ListButtonCollectionViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 20/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

fileprivate extension UIColor {
    static var blueImage: UIColor {
        return UIColor(withHex: 0x3498db, alpha: 1.0)
    }
}

final class ListButtonCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "ListButtonCollectionViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12.0)
        return label
    }()
    
    fileprivate let imageView: UIImageView = {
        let image = UIImageView()
        image.tintColor = UIColor.blueImage
        image.contentMode = .scaleToFill
        return image
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 35.0, height: 35.0))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom)
            make.height.equalTo(15.0)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    var contact: Contact? {
        didSet {
            switch contact?.type {
            case .phone?:
                let phoneImage = UIImage(named: "ic_phone")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                imageView.image = phoneImage
                titleLabel.text = "Call to phone"
            case .website?:
                let browserImage = UIImage(named: "ic_open_in_browser")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                imageView.image = browserImage
                titleLabel.text = "Open website"
            case .facebook?:
                let facebookImage = UIImage(named: "ic_facebook")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                imageView.image = facebookImage
                titleLabel.text = "Open Facebook"
            case .none:
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(titleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
