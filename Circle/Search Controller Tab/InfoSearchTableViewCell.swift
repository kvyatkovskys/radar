//
//  InfoSearchTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 25/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class InfoSearchTableViewCell: UITableViewCell {
    static let cellIdentifier = "InfoSearchTableViewCell"
    
    fileprivate let titleQuerySearch: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("recentlySearched", comment: "Label when queries not empty")
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17.0)
        return label
    }()
    
    var title: String? {
        didSet {
            titleQuerySearch.text = title
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        titleQuerySearch.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(15.0)
            make.top.bottom.equalToSuperview()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(titleQuerySearch)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
