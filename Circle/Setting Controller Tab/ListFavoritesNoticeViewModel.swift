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
    let dataSource: [String]
    
    init() {
        var favorites: [String] = []
        
        do {
            let realm = try Realm()
            favorites = realm.objects(Favorites.self).filter("notify = 1").map({ $0.title ?? "" })
        } catch {
            print(error)
        }
        
        self.dataSource = favorites
    }
}
