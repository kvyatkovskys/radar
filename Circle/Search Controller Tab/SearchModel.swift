//
//  SearchModel.swift
//  Circle
//
//  Created by Kviatkovskii on 03/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

enum SearchDistance: Int {
    case oneThousand, twoThousand, threeThousand, fiveThousand
    
    var title: String {
        switch self {
        case .oneThousand: return NSLocalizedString("1000", comment: "First label section in search bar")
        case .twoThousand: return NSLocalizedString("2500", comment: "Second label section in search bar")
        case .threeThousand: return NSLocalizedString("3500", comment: "Third label section in search bar")
        case .fiveThousand: return NSLocalizedString("5000", comment: "Four label section in search bar")
        }
    }
    
    var value: Double {
        switch self {
        case .oneThousand: return 1000.0
        case .twoThousand: return 2500.0
        case .threeThousand: return 3500.0
        case .fiveThousand: return 5000.0
        }
    }
}

enum ViewType: String {
    case search, savedQueries
}

class Search: Object {
    @objc dynamic var query: String = ""
    @objc dynamic var weigth: Int = 0
    @objc dynamic var date: Date = Date()
    @objc dynamic var location: Location?
}
