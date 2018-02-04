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
    case facebook, favorites, search
    
    var title: String {
        switch self {
        case .facebook: return "Conntect to Facebook"
        case .favorites: return "Favorites"
        case .search: return "Search"
        }
    }
}

enum SettingRowType {
    case facebookLogin
    case clearFavorites(title: String, description: String, image: UIImage, color:UIColor)
    case clearHistorySearch(title: String, description: String, image: UIImage, color:UIColor)
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
    let items: [SettingsObject] = [SettingsObject(.search, [.clearHistorySearch(title: "Clear search history",
                                                                                   description: "Are you sure you to clear search history?",
                                                                                   image: UIImage(named: "ic_delete_forever")!.withRenderingMode(.alwaysTemplate),
                                                                                   color: UIColor.red)]),
                                   SettingsObject(.favorites, [.clearFavorites(title: "Clear Favorites",
                                                                               description: "Are you sure you want to clear all items in your Favorites?",
                                                                               image: UIImage(named: "ic_delete_forever")!.withRenderingMode(.alwaysTemplate),
                                                                               color: UIColor.red)]),
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
    
    /// deleted search history
    func deleteSearchHistory() {
        do {
            let realm = try Realm()
            let favorite = realm.objects(Search.self)
            
            try realm.write {
                realm.delete(favorite)
            }
        } catch {
            print(error)
        }
    }
}
