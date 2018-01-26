//
//  DetailRestaurantServiceTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 26/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DetailRestaurantServiceTableViewCell: UITableViewCell {
    static let cellIdentifier = "DetailRestaurantServiceTableViewCell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
