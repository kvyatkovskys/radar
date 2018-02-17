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
        let blur = UIBlurEffect(style: .extraLight)
        let blurView = RoundedVisualEffectView(effect: blur)
        blurView.bounds = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
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
        
        imageCell.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(5.0)
            make.bottom.top.equalToSuperview().inset(8.0)
        }
        
        mainView.snp.makeConstraints { (make) in
            make.bottom.equalTo(imageCell)
            make.left.right.equalToSuperview().inset(5.0)
            make.height.equalTo(60.0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(10.0)
            make.top.equalToSuperview()
            make.height.equalTo(30.0)
        }

        ratingLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(titleLabel)
            make.width.lessThanOrEqualTo(100.0)
            make.bottom.equalToSuperview()
        }

        categoryLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(10.0)
            make.size.equalTo(CGSize(width: 70.0, height: 20.0))
            make.centerY.equalTo(ratingLabel)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(imageCell)
        addSubview(mainView)
        mainView.addSubview(titleLabel)
        mainView.addSubview(ratingLabel)
        mainView.addSubview(categoryLabel)
        
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
