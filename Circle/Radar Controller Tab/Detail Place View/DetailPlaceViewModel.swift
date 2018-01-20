//
//  DetailPlaceViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

enum ContactType: String {
    case phone, website, facebook
}

typealias Contact = (type: ContactType, value: Any?)

enum TypeDetailCell {
    case description(String, CGFloat)
    case contact([Contact]) //Int?, String?, URL?
    case address(String, LocationPlace?, CGFloat)
    
    var title: String {
        switch self {
        case .description:
            return "Description"
        case .contact:
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
        var items: [DetailSectionObjects] = []
        
        if (place.info.phone != nil) || (place.info.website != nil) || (place.info.appLink != nil) {
            let itemsContact = [Contact(type: ContactType.phone, value: place.info.phone),
                                Contact(type: ContactType.website, value: place.info.website),
                                Contact(type: ContactType.facebook, value: place.info.appLink)]
            let type = TypeDetailCell.contact(itemsContact)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        if let address = place.info.address {
            let height = address.height(font: .boldSystemFont(ofSize: 15.0),
                                        width: ScreenSize.SCREEN_WIDTH) + 80.0
            let type = TypeDetailCell.address(address, place.info.location, height)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        if let description = place.info.description {
            let height = description.height(font: .systemFont(ofSize: 14.0),
                                            width: ScreenSize.SCREEN_WIDTH) + 20.0
            let type = TypeDetailCell.description(description, height)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        self.dataSource = items
    }
}
