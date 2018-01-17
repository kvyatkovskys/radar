//
//  DetailPlaceViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

enum TypeDetailCell {
    case description(String, CGFloat)
    case phoneAndSite(Int?, String?)
    case address(String, CGFloat)
}

struct DetailPlaceViewModel {
    let place: Place
    var dataSource: [TypeDetailCell]
    
    init(_ place: Place) {
        self.place = place
        print(place.info.categories)
        var items: [TypeDetailCell] = []
        
        if (place.info.phone != nil) || (place.info.website != nil) {
            let type = TypeDetailCell.phoneAndSite(place.info.phone, place.info.website)
            items.append(type)
        }
        
        if let address = place.info.address {
            let rect = address.boundingRect(with: CGSize(width: ScreenSize.SCREEN_WIDTH, height: CGFloat.greatestFiniteMagnitude),
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: UIFont.boldSystemFont(ofSize: 15.0)],
                                            context: nil)
            
            let type = TypeDetailCell.address(address, rect.height + 80.0)
            items.append(type)
        }
        
        if let description = place.info.description {
            let rect = description.boundingRect(with: CGSize(width: ScreenSize.SCREEN_WIDTH, height: CGFloat.greatestFiniteMagnitude),
                                                options: .usesLineFragmentOrigin,
                                                attributes: [.font: UIFont.systemFont(ofSize: 14.0)],
                                                context: nil)
            
            let type = TypeDetailCell.description(description, rect.height + 20.0)
            items.append(type)
        }
        
        self.dataSource = items
    }
}
