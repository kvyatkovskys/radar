//
//  SearchModel.swift
//  Circle
//
//  Created by Kviatkovskii on 03/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

class Search: Object {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    let searchQuery = List<String>()
}
