//
//  FavoritesModel.swift
//  Circle
//
//  Created by Kviatkovskii on 01/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

struct FavoritesModel {
    let id: Int
    let name: String?
    let title: NSMutableAttributedString?
    let rating: NSMutableAttributedString?
    let picture: URL?
    let categories: [Categories]?
    let subCategories: [String]?
    let ratingStar: Float?
    let ratingCount: Int?
    let about: String?
    let website: String?
}

class Favorites: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var about: String?
    @objc dynamic var picture: String?
    @objc dynamic var ratingStar: Float = 0
    @objc dynamic var ratingCount: Int = 0
    @objc dynamic var date: Date = Date()
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    let categories = List<String>()
    let subCategories = List<String>()
    @objc dynamic var notify: Bool = false
    @objc dynamic var website: String?
}
