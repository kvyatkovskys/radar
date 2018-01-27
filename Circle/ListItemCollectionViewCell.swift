//
//  ListitemCollectionViewCell.swift
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

final class ListItemCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "ListItemCollectionViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12.0)
        return label
    }()
    
    fileprivate let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top)
            make.width.equalTo(35.0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom)
            make.height.equalTo(15.0)
            make.bottom.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    var payment: PaymentType? {
        didSet {
            imageView.image = payment?.image
            titleLabel.text = payment?.title
        }
    }
    
    var parking: ParkingType? {
        didSet {
            imageView.tintColor = UIColor.blueImage
            imageView.image = parking?.image
            titleLabel.text = parking?.title
        }
    }
    
    var service: RestaurantServiceType? {
        didSet {
            imageView.tintColor = UIColor.blueImage
            imageView.image = service?.image
            titleLabel.text = service?.title
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
