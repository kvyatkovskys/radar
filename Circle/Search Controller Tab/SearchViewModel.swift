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

typealias Query = (query: String, weight: Int)

struct SearchViewModel {
    fileprivate let placeViewModel: PlaceViewModel
    
    var searchQueries: [Query] {
        var queries: [Query] = []
        do {
            let realm = try Realm()
            let search = realm.objects(Search.self).filter("query != ''").map({ $0.query })
            queries = search.reduce(into: [], { (acc, query) in
                if let index = acc?.index(where: { $0.query == query }) {
                    acc![index].weight += 1
                } else {
                    acc?.append(Query(query, 0))
                }
            }) ?? []
        } catch {
            print(error)
        }

        let endRange = queries.count >= 6 ? 6 : queries.count
        return queries.sorted(by: { $0.weight > $1.weight })[0..<endRange].map({ $0 })
    }
    
    /// open detail place controller
    var openDetailPlace: ((_ place: PlaceModel, _ title: NSMutableAttributedString?, _ rating: NSMutableAttributedString?, _ favoritesViewModel: FavoritesViewModel) -> Void) = {_, _, _, _ in }
    
    init(_ placeViewModel: PlaceViewModel) {
        self.placeViewModel = placeViewModel
    }
    
    func searchQuery(_ query: String, _ distance: Double) -> Observable<Places> {
        var location = CLLocation()
        
        do {
            let realm = try Realm()
            let locationModel = realm.objects(Location.self).last
            location = CLLocation(latitude: locationModel?.latitude ?? 0.0, longitude: locationModel?.longitude ?? 0.0)
        } catch {
            print(error)
        }
        
        return placeViewModel.getInfoPlaces(location: location, distance: distance, searchTerm: query)
            .asObservable()
            .flatMap({ (model) -> Observable<Places> in
                return Observable.just(model)
            })
        .share(replay: 1, scope: .forever)
    }
    
    func saveQuerySearch(_ query: String) {
        do {
            let realm = try Realm()
            let searchModel = Search()
            let location = realm.objects(Location.self).last
            
            searchModel.query = query
            searchModel.date = Date()
            searchModel.location = location
            
            try realm.write {
                realm.add(searchModel)
            }
    } catch {
            print(error)
        }
    }
}
