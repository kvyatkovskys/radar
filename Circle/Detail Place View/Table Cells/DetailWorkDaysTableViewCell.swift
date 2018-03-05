//
//  DetailWorkDaysTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 21/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DetailWorkDaysTableViewCell: UITableViewCell, UICollectionViewDelegate {    
    static let cellIdentifier = "DetailWorkDaysTableViewCell"

    fileprivate lazy var listWorkDaysViewController: WorkDaysViewController = {
        let list = WorkDaysViewController(workDays: nil)
        list.view.frame = contentView.frame
        contentView.addSubview(list.view)
        return list
    }()
    
    var workDays: WorkDays? {
        didSet {
            listWorkDaysViewController.reloadedData(workDays: workDays)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
