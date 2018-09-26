//
//  DetailItemsTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 24/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DetailItemsTableViewCell: UITableViewCell, UICollectionViewDelegate {
    static let cellIdentifier = "DetailItemsTableViewCell"
    
    fileprivate lazy var listItemsViewController: ListItemsViewController = {
        let list = ListItemsViewController(payments: [], parkings: [])
        list.view.frame = contentView.frame
        contentView.addSubview(list.view)
        return list
    }()
    
    var payments: [PaymentType?] = [] {
        didSet {
            listItemsViewController.reloadedData(payments: payments, parkings: [])
        }
    }
    
    var parkings: [ParkingType?] = [] {
        didSet {
            listItemsViewController.reloadedData(payments: [], parkings: parkings)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
