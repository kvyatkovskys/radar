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
import RxCocoa
import Swinject
import Kingfisher

struct SearchViewModel {
    fileprivate let disposeBag = DisposeBag()
    let placeViewModel: PlaceViewModel
    var dataSourceQueries: BehaviorRelay<[String]> = {
        var queries: [String] = []
        do {
            let realm = try Realm()
            queries = realm.objects(Search.self)
                .filter("query != ''")
                .sorted(byKeyPath: "weigth", ascending: false)
                .distinct(by: ["query"])
                .map({ $0.query })
        } catch {
            print(error)
        }

        let endRange = queries.count >= 6 ? 6 : queries.count
        queries = queries[0..<endRange].map({ $0.localizedCapitalized })
        queries.insert(NSLocalizedString("tryToFind", comment: "Label when queries empty"), at: 0)
        return BehaviorRelay(value: queries)
    }()
    var viewType = ViewType.search
    let kingfisherOptions: KingfisherOptionsInfo?
    let searchQuery = BehaviorRelay(value: "")
    
    /// open detail place controller
    var openDetailPlace: ((PlaceModel, FavoritesViewModel) -> Void) = { _, _ in }
    
    init(_ container: Container) {
        self.placeViewModel = container.resolve(PlaceViewModel.self)!
        self.kingfisherOptions = container.resolve(KingfisherOptionsInfo.self)
    }
    
    func searchQuery(_ query: String, _ distance: Double) {
        var location = CLLocation()
        do {
            let realm = try Realm()
            let locationModel = realm.objects(Location.self).last
            location = CLLocation(latitude: locationModel?.latitude ?? 0.0, longitude: locationModel?.longitude ?? 0.0)
            placeViewModel.getPlaces(location: location, distance: distance, searchTerm: query)
        } catch {
            print(error)
        }
    }
    
    func saveQuerySearch(_ query: String) {
        do {
            let realm = try Realm()
            let search = Search()
            let offset = query.count >= 4 ? 4 : query.count
            let indexEndString = query.index(query.startIndex, offsetBy: offset)
            
            let oldSearch = realm.objects(Search.self)
                .filter("query CONTAINS '\(query[..<indexEndString].lowercased())'")
                .sorted(byKeyPath: "weigth", ascending: false)
            let location = realm.objects(Location.self).last
            
            try realm.write {
                guard let old = oldSearch.first else {
                    search.query = query.lowercased()
                    search.weigth = 1
                    search.date = Date()
                    search.location = location
                    realm.add(search)
                    return
                }
                
                old.date = Date()
                old.weigth += 1
                old.location = location
            }
        } catch {
            print(error)
        }
    }
}
