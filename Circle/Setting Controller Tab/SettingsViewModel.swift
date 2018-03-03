//
//  SettingsViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 13/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

fileprivate extension UIColor {
    static var deleted: UIColor {
        return UIColor(withHex: 0xF62232, alpha: 1.0)
    }
    
    static var notify: UIColor {
        return UIColor(withHex: 0x5796DB, alpha: 1.0)
    }
    
    static var standardGray: UIColor {
        return UIColor(withHex: 0x8C9EA0, alpha: 1.0)
    }
}

enum SettingType: String {
    case facebook, favorites, search, app
    
    var title: String {
        switch self {
        case .facebook: return "Conntect to Facebook"
        case .favorites: return "Favorites"
        case .search: return "Search"
        case .app: return ""
        }
    }
}

enum SettingRowType {
    case facebookLogin
    case listFavoritesNoticy(title: String, description: String, image: UIImage, color: UIColor)
    case favoriteNotify(title: String, enabled: Bool, image: UIImage, color: UIColor)
    case clearFavorites(title: String, description: String, image: UIImage, color: UIColor)
    case clearHistorySearch(title: String, description: String, image: UIImage, color: UIColor)
    case showSearchHistory(title: String, image: UIImage, color: UIColor)
    case openSettings(title: String, image: UIImage, color: UIColor)
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
    let items: [SettingsObject]
    
    /// open search history modal view
    var openSearchHistory: (() -> Void) = { }
    
    var openListFavoritesNotice: (() -> Void) = { }
    
    init() {
        let settingsApp: [SettingRowType] = [.openSettings(title: NSLocalizedString("openSettings",
                                                                                    comment: "The title for button that open settings"),
                                                           image: UIImage(named: "ic_settings_app")!.withRenderingMode(.alwaysTemplate),
                                                           color: .standardGray)]
        
        let searchObjects: [SettingRowType] = [.showSearchHistory(title: NSLocalizedString("showHistory",
                                                                                           comment: "Thet title for button that show history"),
                                                image: UIImage(named: "ic_history")!.withRenderingMode(.alwaysTemplate),
                                                color: .standardGray),
                             .clearHistorySearch(title: NSLocalizedString("clearHistory",
                                                                          comment: "The title for button that clear history"),
                                                 description: NSLocalizedString("alertClearHistory",
                                                                                comment: "Text for clear history alert"),
                                                 image: UIImage(named: "ic_delete_forever")!.withRenderingMode(.alwaysTemplate),
                                                 color: .deleted)]
        
        var disabledNotice = false
        do {
            let realm = try Realm()
            let settings = realm.objects(Settings.self).first
            if let settings = settings {
                disabledNotice = settings.disabledNotice
            }
        } catch {
            print(error)
        }
        
        let favoritesObjects: [SettingRowType] = [.listFavoritesNoticy(title: NSLocalizedString("listNotice",
                                                                                                comment: "The title for button that list notice"),
                                                                       description: "",
                                                                       image: UIImage(named: "ic_list")!.withRenderingMode(.alwaysTemplate),
                                                                       color: .standardGray),
                                                  .favoriteNotify(title: NSLocalizedString("disableNotice",
                                                                                           comment: "The title for the button that disable notice"),
                                                                  enabled: disabledNotice,
                                                                  image: UIImage(named: "ic_notifications")!.withRenderingMode(.alwaysTemplate),
                                                                  color: .notify),
                                                  .clearFavorites(title: NSLocalizedString("clearFavorites",
                                                                                           comment: "The title for the button that clear favorates"),
                                                                  description: NSLocalizedString("alertClearFavorites",
                                                                                                 comment: "Text for clear favorites alert"),
                                                                  image: UIImage(named: "ic_delete_forever")!.withRenderingMode(.alwaysTemplate),
                                                                  color: .deleted)]
        
        let facebookObjects: [SettingRowType] = [.facebookLogin]
        
        self.items = [SettingsObject(.app, settingsApp),
                      SettingsObject(.search, searchObjects),
                      SettingsObject(.favorites, favoritesObjects),
                      SettingsObject(.facebook, facebookObjects)]
    }
    
    func openSettingsPhone() {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    /// disabled all notifications for favorites the places
    func disabledNotice(_ isOn: Bool) {
        do {
            let realm = try Realm()
            let settings = realm.objects(Settings.self).first
            
            try realm.write {
                guard let oldSettings = settings else {
                    let newSettings = Settings()
                    newSettings.disabledNotice = isOn
                    realm.add(newSettings)
                    return
                }
                oldSettings.disabledNotice = isOn
            }
        } catch {
            print(error)
        }
    }
    
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
            let search = realm.objects(Search.self)
            
            try realm.write {
                realm.delete(search)
            }
        } catch {
            print(error)
        }
    }
}
