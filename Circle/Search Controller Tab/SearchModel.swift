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
    @objc dynamic var query: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var location: Location?
}
