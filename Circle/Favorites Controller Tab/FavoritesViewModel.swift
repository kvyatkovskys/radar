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
    var favoritePlaces: [FavoritesModel] = []
    
    init() {
        var favorites: [Favorites] = []
        do {
            let realm = try Realm()
            favorites = realm.objects(Favorites.self).map({ $0 })
        } catch {
            print(error)
        }
        self.favoritePlaces = updateValue(favorites.sorted(by: { $0.date! > $1.date! }))
    }
    
    func updateValue(_ favorites: [Favorites]) -> [FavoritesModel] {
        var result: [FavoritesModel] = []
        
        favorites.forEach { (item) in
            let ratingStar = NSAttributedString(string: "\(item.ratingStar)",
                attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17.0),
                             NSAttributedStringKey.foregroundColor: colorForRating(item.ratingStar)])
            let ratingCount = NSAttributedString(string: " \(item.ratingCount)",
                attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0),
                             NSAttributedStringKey.foregroundColor: UIColor.gray])
            
            let resultRating = NSMutableAttributedString(attributedString: ratingStar)
            resultRating.append(ratingCount)
            
            let title = NSAttributedString(string: "\(item.title ?? "")",
                attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17.0),
                             NSAttributedStringKey.foregroundColor: UIColor.black])
            let about = NSAttributedString(string: "\n\n\(item.about ?? "")",
                attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0),
                             NSAttributedStringKey.foregroundColor: UIColor.gray])
            
            let resultTitle = NSMutableAttributedString(attributedString: title)
            resultTitle.append(about)
            
            result.append(FavoritesModel(id: item.id,
                                         title: resultTitle,
                                         rating: resultRating,
                                         picture: URL(string: item.picture ?? ""),
                                         categories: item.categories.map({ Categories(rawValue: $0)! })))
        }
        
        return result
    }
    
    fileprivate func colorForRating(_ rating: Float) -> UIColor {
        var color = UIColor()
        switch rating {
        case 3.4...5.0:
            color = UIColor(withHex: 0x2ecc71, alpha: 1.0)
        case 1.8...3.4:
            color = .black
        default:
            color = UIColor(withHex: 0xc0392b, alpha: 1.0)
        }
        return color
    }
    
    /// check, if place adding to favorites
    func checkAddingToFavorites(_ place: Place) -> Bool {
        var favorites: [Favorites] = []
        do {
            let realm = try Realm()
            favorites = realm.objects(Favorites.self).map({ $0 })
        } catch {
            print(error)
        }
        
        return favorites.contains(where: { $0.id == place.info.id })
    }
    
    /// added to favorites
    func addToFavorite(place: PlaceModel) {
        do {
            let realm = try Realm()
            let favorite = Favorites()
            
            favorite.id = place.id
            favorite.title = place.name
            favorite.about = place.about
            favorite.ratingCount = place.ratingCount ?? 0
            favorite.ratingStar = place.ratingStar ?? 0
            favorite.date = Date()
            
            place.categories?.forEach({ category in
                favorite.categories.append(category.rawValue)
            })
            
            if let url = place.coverPhoto {
                favorite.picture = url.absoluteString
            }
            
            try realm.write {
                realm.add(favorite)
            }
        } catch {
            print(error)
        }
    }
    
    /// deleted from favorites
    func deleteFromFavorites(id: Int) {
        do {
            let realm = try Realm()
            let favorite = realm.objects(Favorites.self).filter("id = \(id)")
            
            try realm.write {
                realm.delete(favorite)
            }
        } catch {
            print(error)
        }
    }
}
