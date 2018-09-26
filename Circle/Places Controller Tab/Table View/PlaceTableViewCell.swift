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

final class PlaceTableViewCell: UITableViewCell {
    static let cellIndetifier = "PlaceTableViewCell"
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    fileprivate let viewImage: KSView = {
        let view = KSView()
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
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17.0)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    fileprivate let ratingLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    fileprivate let categoryLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 10.0
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 13.0)
        label.textColor = .white
        return label
    }()
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var rating: NSMutableAttributedString? {
        didSet {
            ratingLabel.attributedText = rating
        }
    }
    
    var colorCategory: UIColor? {
        didSet {
            guard colorCategory != nil else {
                categoryLabel.backgroundColor = .clear
                return
            }
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
        
        viewImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10.0)
            make.left.right.equalToSuperview().inset(10.0)
            make.bottom.equalTo(mainView.snp.top)
        }
        
        imageCell.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(viewImage)
        }
        
        mainView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.right.equalTo(imageCell)
            make.height.equalTo(60.0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(30.0)
        }

        ratingLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(titleLabel)
            make.width.lessThanOrEqualTo(100.0)
            make.bottom.equalToSuperview()
        }

        categoryLabel.snp.remakeConstraints { (make) in
            make.right.equalTo(imageCell).offset(-24)
            make.height.equalTo(20.0)
            make.bottom.equalTo(imageCell)
            make.width.equalTo(82)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(viewImage)
        viewImage.addSubview(imageCell)
        addSubview(mainView)
        mainView.addSubview(titleLabel)
        mainView.addSubview(ratingLabel)
        addSubview(categoryLabel)
        
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
