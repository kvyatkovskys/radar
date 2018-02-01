//
//  FavoritesModel.swift
//  Circle
//
//  Created by Kviatkovskii on 01/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

class Favorites: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var about: String?
    @objc dynamic var picture: Data?
    @objc dynamic var ratingStar: Float = 0
    @objc dynamic var ratingCount: Int = 0
    let categories = List<String>()
}
