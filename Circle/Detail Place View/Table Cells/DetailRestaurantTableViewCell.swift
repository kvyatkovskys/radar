//
//  DetailRestaurantTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 26/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

typealias RestaurantService = (services: [RestaurantServiceType?], color: UIColor?)
typealias RestaurantSpeciality = (specialties: [RestaurantSpecialityType?], color: UIColor?)

final class DetailRestaurantTableViewCell: UITableViewCell, UICollectionViewDelegate {
    static let cellIdentifier = "DetailRestaurantTableViewCell"
    
    fileprivate lazy var restaurantViewController: ListRestaurantViewController = {
        let list = ListRestaurantViewController(service: nil, speciality: nil)
        list.view.frame = contentView.frame
        contentView.addSubview(list.view)
        return list
    }()
    
    var restaurantService: RestaurantService? {
        didSet {
            restaurantViewController.reloadedData(service: restaurantService, speciality: nil)
        }
    }
    
    var restaurantSpeciatity: RestaurantSpeciality? {
        didSet {
            restaurantViewController.reloadedData(service: nil, speciality: restaurantSpeciatity)
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
