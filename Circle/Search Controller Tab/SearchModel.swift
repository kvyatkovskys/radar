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
        case .oneThousand: return "1000 m"
        case .twoThousand: return "2500 m"
        case .threeThousand: return "3500 m"
        case .fiveThousand: return "5000 m"
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
