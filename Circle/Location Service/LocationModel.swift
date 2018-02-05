//
//  LocationModel.swift
//  Circle
//
//  Created by Kviatkovskii on 05/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

class Location: Object {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var altitude: Double = 0.0
    @objc dynamic var horizontalAccuracy: Double = 0.0
    @objc dynamic var speed: Double = 0.0
    @objc dynamic var timestamp: Date?
    @objc dynamic var verticalAccuracy: Double = 0.0
    @objc dynamic var street: String?
    @objc dynamic var city: String?
    @objc dynamic var country: String?
    @objc dynamic var region: String?
}
