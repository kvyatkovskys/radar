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
    case address(String, LocationPlace?, CGFloat)
    
    var title: String {
        switch self {
        case .description:
            return "Description"
        case .phoneAndSite:
            return "Contacts"
        case .address:
            return "Address"
        }
    }
}

struct DetailSectionObjects {
    var sectionName: String
    var sectionObjects: [TypeDetailCell]
}

struct DetailPlaceViewModel {
    let place: Place
    var dataSource: [DetailSectionObjects]
    
    init(_ place: Place) {
        self.place = place
        print(place.info.categories)
        var items: [DetailSectionObjects] = []
        
        if (place.info.phone != nil) || (place.info.website != nil) {
            let type = TypeDetailCell.phoneAndSite(place.info.phone, place.info.website)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        if let address = place.info.address {
            let rect = address.boundingRect(with: CGSize(width: ScreenSize.SCREEN_WIDTH, height: CGFloat.greatestFiniteMagnitude),
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: UIFont.boldSystemFont(ofSize: 15.0)],
                                            context: nil)
            
            let type = TypeDetailCell.address(address, place.info.location, rect.height + 80.0)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        if let description = place.info.description {
            let rect = description.boundingRect(with: CGSize(width: ScreenSize.SCREEN_WIDTH, height: CGFloat.greatestFiniteMagnitude),
                                                options: .usesLineFragmentOrigin,
                                                attributes: [.font: UIFont.systemFont(ofSize: 14.0)],
                                                context: nil)
            
            let type = TypeDetailCell.description(description, rect.height + 20.0)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        self.dataSource = items
    }
}
