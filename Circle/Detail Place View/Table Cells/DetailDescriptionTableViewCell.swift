//
//  DetailDescriptionTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DetailDescriptionTableViewCell: UITableViewCell {
    static let cellIdentifier = "DetailDescriptionTableViewCell"
    
    fileprivate let descriptionText: UITextView = {
        let text = UITextView()
        text.font = .systemFont(ofSize: 16.0)
        text.isEditable = false
        text.isScrollEnabled = false
        return text
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        descriptionText.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(10.0)
        }
    }
    
    var textDescription: String? {
        didSet {
            descriptionText.text = textDescription
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(descriptionText)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
