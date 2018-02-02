//
//  DetailSectionTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 19/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DetailSectionTableViewCell: UITableViewCell {
    static let cellIdentifier = "DetailSectionTableViewCell"
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20.0)
        label.textColor = .black
        return label
    }()

    fileprivate let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        lineView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
            make.right.left.equalToSuperview().inset(10.0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineView)
            make.left.equalToSuperview().offset(10.0)
            make.right.equalToSuperview().offset(-10.0)
            make.bottom.equalToSuperview().offset(-5.0)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.white
        addSubview(lineView)
        addSubview(titleLabel)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
