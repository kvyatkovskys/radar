//
//  ListFavoritesNoticeViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 09/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

struct ListFavoritesNoticeViewModel {
    var dataSource: [Favorites]
    
    init() {
        var favorites: [Favorites] = []
        
        do {
            let realm = try Realm()
            favorites = realm.objects(Favorites.self).sorted(byKeyPath: "date", ascending: false).map({ $0 })
        } catch {
            print(error)
        }
        
        self.dataSource = favorites
    }
    
    func selectNotify(_ favorite: Favorites) {
        do {
            let realm = try Realm()
            let favorites = realm.objects(Favorites.self).filter("id = \(favorite.id)").first
            
            if let favorite = favorites {
                try realm.write {
                    favorite.notify = !favorite.notify
                }
            }
        } catch {
            print(error)
        }
    }
}
