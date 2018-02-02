//
//  SettingsViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 13/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

enum SettingType: String {
    case facebook, favorites
    
    var title: String {
        switch self {
        case .facebook: return "Conntect to Facebook"
        case .favorites: return "Favorites"
        }
    }
}

enum SettingRowType {
    case facebookLogin
    case clearFavorites(String, UIImage, UIColor)
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
    let items: [SettingsObject] = [SettingsObject(.favorites, [.clearFavorites("Clear Favorites",
                                                                               UIImage(named: "ic_delete_forever")!.withRenderingMode(.alwaysTemplate),
                                                                               UIColor.red)]),
                                   SettingsObject(.facebook, [.facebookLogin])]
    
    /// deleted all objects from favorites
    func deleteAllFavorites() {
        do {
            let realm = try Realm()
            let favorite = realm.objects(Favorites.self)
            
            try realm.write {
                realm.delete(favorite)
            }
        } catch {
            print(error)
        }
    }
}
