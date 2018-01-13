//
//  SettingsViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 13/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

enum SettingType: String {
    case facebook
    
    var title: String {
        switch self {
        case .facebook:
            return "Facebook"
        }
    }
}

enum SettingRowType: String {
    case facebookLogin
}

struct SettingsObject {
    var sectionName: SettingType
    var sectionObjects: [SettingRowType]
    
    init(_ name: SettingType, _ objects: [SettingRowType]) {
        self.sectionName = name
        self.sectionObjects = objects
    }
}

struct SettingsViewModel {
    let items: [SettingsObject] = [SettingsObject(SettingType.facebook, [SettingRowType.facebookLogin])]
}
