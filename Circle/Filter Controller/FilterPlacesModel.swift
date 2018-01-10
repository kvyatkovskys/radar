//
//  FilterPlacesModel.swift
//  Circle
//
//  Created by Kviatkovskii on 03/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

struct FilterModel {
    let title: String
}

struct FilterCategoriesModel {
    let category: Categories
}

class FilterSelectedCategory: Object {
    @objc dynamic var category: String = ""
    @objc dynamic var index: Int = 0
}

struct FilterDistanceModel {
    let title: String
    let value: Double
}
