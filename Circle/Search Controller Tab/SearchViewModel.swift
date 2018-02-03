//
//  SearchViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 02/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

struct SearchViewModel {
    fileprivate let placeViewModel: PlaceViewModel
    let searchQueries: [String]
    /// open detail place controller
    var openDetailPlace: ((_ place: PlaceModel, _ title: NSMutableAttributedString?, _ rating: NSMutableAttributedString?, _ favoritesViewModel: FavoritesViewModel) -> Void) = {_, _, _, _ in }
    
    init(_ placeViewModel: PlaceViewModel) {
        self.placeViewModel = placeViewModel
        
        var queries: [String] = []
        do {
            let realm = try Realm()
            let search = realm.objects(Search.self).flatMap({ $0.searchQuery })
            queries = search.map({ $0 }).reduce([], { $0.contains($1) ? $0 : $0 + [$1]})
        } catch {
            print(error)
        }
        self.searchQueries = queries
    }
    
    func searchQuery(_ query: String, _ distance: Double) -> Observable<Places> {
        var location = CLLocation()
        
        do {
            let realm = try Realm()
            let searchModel = realm.objects(Search.self).first
            location = CLLocation(latitude: searchModel?.latitude ?? 0.0, longitude: searchModel?.longitude ?? 0.0)
        } catch {
            print(error)
        }
        
        return placeViewModel.getInfoPlaces(location: location, distance: distance, searchTerm: query)
            .asObservable()
            .flatMap({ (model) -> Observable<Places> in
                return Observable.just(model)
            })
    }
    
    func saveQuerySearch(_ query: String) {
        do {
            let realm = try Realm()
            if let searchModel = realm.objects(Search.self).first {
                searchModel.searchQuery.append(query)
                
                try realm.write {
                    realm.add(searchModel)
                }
            }
        } catch {
            print(error)
        }
    }
}
