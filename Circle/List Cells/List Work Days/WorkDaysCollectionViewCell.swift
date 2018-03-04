//
//  WorkDaysCollectionViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 21/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class WorkDaysCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "WorkDaysCollectionViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14.0)
        return label
    }()
    
    fileprivate let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 11.0)
        return label
    }()
    
    fileprivate let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 1.0
        return view
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5.0)
            make.left.right.equalToSuperview().inset(2.0)
            make.height.equalTo(15.0)
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.right.left.equalTo(titleLabel)
            make.bottom.equalTo(lineView.snp.top)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(3.0)
            make.bottom.equalToSuperview()
            make.height.equalTo(2.0)
        }
    }
    
    var day: String? {
        didSet {
            titleLabel.text = day
        }
    }
    
    var hours: String? {
        didSet {
            valueLabel.text = hours
        }
    }
    
    var colorCurrentDay: UIColor? {
        didSet {
            lineView.backgroundColor = colorCurrentDay
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(lineView)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
