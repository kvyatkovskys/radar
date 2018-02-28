//
//  SettingsModel.swift
//  Circle
//
//  Created by Kviatkovskii on 09/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

class Settings: Object {
    @objc dynamic var disabledNotice: Bool = false
    @objc dynamic var cancelNotice: Bool = false
    @objc dynamic var typeViewMainTab: Int = 0
}
