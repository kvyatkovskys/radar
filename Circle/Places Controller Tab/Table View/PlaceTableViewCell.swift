//
//  PlaceTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 31/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate extension UIColor {
    static var shadowGray: UIColor {
        return UIColor(withHex: 0xecf0f1, alpha: 1.0)
    }
}

final class PlaceTableViewCell: UITableViewCell {
    static let cellIndetifier = "PlaceTableViewCell"
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
        view.layer.shadowRadius = 6.0
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        return view
    }()
    
    let imageCell: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .shadowGray
        image.layer.cornerRadius = 5.0
        return image
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17.0)
        return label
    }()
    
    fileprivate let ratingLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    fileprivate let categoryLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 8.0
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 11.0)
        label.textColor = .white
        return label
    }()
    
    var title: NSMutableAttributedString? {
        didSet {
            titleLabel.attributedText = title
        }
    }
    
    var rating: NSMutableAttributedString? {
        didSet {
            ratingLabel.attributedText = rating
        }
    }
    
    var colorCategory: UIColor? {
        didSet {
            guard colorCategory != nil else { return }
            categoryLabel.backgroundColor = colorCategory
        }
    }
    
    var titleCategory: String? {
        didSet {
            categoryLabel.text = titleCategory
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
            make.top.equalToSuperview().offset(10.0)
            make.right.equalToSuperview().inset(10.0)
            make.bottom.equalTo(ratingLabel.snp.top).offset(-10.0)
        }
        
        ratingLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(mainView).offset(-10.0)
            make.left.equalTo(imageCell.snp.right).offset(10.0)
            make.width.lessThanOrEqualTo(60.0)
            make.height.equalTo(15.0)
        }
        
        categoryLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(ratingLabel)
            make.width.equalTo(70.0)
            make.right.equalToSuperview().inset(10.0)
            make.height.equalTo(ratingLabel)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        addSubview(mainView)
        mainView.addSubview(imageCell)
        mainView.addSubview(titleLabel)
        mainView.addSubview(ratingLabel)
        mainView.addSubview(categoryLabel)
        
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
