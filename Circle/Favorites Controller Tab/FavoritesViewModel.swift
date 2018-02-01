//
//  FavoritesViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 01/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

struct FavoritesViewModel {
    let favorites: [Favorites]
    let isAddFavorite: Bool
    
    init(_ place: PlaceModel) {
        var favorites: [Favorites] = []
        do {
            let realm = try Realm()
            favorites = realm.objects(Favorites.self).map({ $0 })
        } catch {
            print(error)
        }
        
        self.isAddFavorite = favorites.contains(where: { $0.id == place.id })
        self.favorites = favorites
    }
    
    func checkAddingToFavorites(_ place: PlaceModel) -> Bool {
        var favorites: [Favorites] = []
        do {
            let realm = try Realm()
            favorites = realm.objects(Favorites.self).map({ $0 })
        } catch {
            print(error)
        }
        
        return favorites.contains(where: { $0.id == place.id })
    }
    
    func addToFavorite(place: PlaceModel) {
        do {
            let realm = try Realm()
            let favorite = Favorites()
            
            favorite.id = place.id
            favorite.title = place.name
            favorite.about = place.about
            favorite.ratingCount = place.ratingCount ?? 0
            favorite.ratingStar = place.ratingStar ?? 0
            
            place.categories?.forEach({ category in
                favorite.categories.append(category.rawValue)
            })
            
            if let url = place.coverPhoto {
                favorite.picture = try Data(contentsOf: url)
            }
            
            try realm.write {
                realm.add(favorite)
            }
        } catch {
            print(error)
        }
    }
    
    func deleteFromFavorites(place: PlaceModel) {
        do {
            let realm = try Realm()
            let favorite = realm.objects(Favorites.self).filter("id = \(place.id)")
            
            try realm.write {
                realm.delete(favorite)
            }
        } catch {
            print(error)
        }
    }
}
