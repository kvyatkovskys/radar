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
    
    init(_ placeViewModel: PlaceViewModel) {
        self.placeViewModel = placeViewModel
    }
    
    func searchQuery(_ query: String) -> Observable<Places> {
        var location = CLLocation()
        
        do {
            let realm = try Realm()
            let searchModel = realm.objects(Search.self).first
            location = CLLocation(latitude: searchModel?.latitude ?? 0.0, longitude: searchModel?.longitude ?? 0.0)
        } catch {
            print(error)
        }
        
        return placeViewModel.getInfoPlaces(location: location, distance: FilterDistanceViewModel().defaultDistance, searchTerm: query)
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
