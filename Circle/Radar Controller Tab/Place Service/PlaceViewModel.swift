//
//  PlaceViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 01/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

struct PlacesSections {
    let sections: [[Categories]]
    let places: [[PlaceModel]]
    
    init(_ places: [[PlaceModel]], _ sections: [[Categories]]) {
        self.places = places
        self.sections = sections
    }
}

struct PlaceViewModel {
    fileprivate let placeService: PlaceService
    /// open filter controller
    var openFilter: ((_ delegate: FilterPlacesDelegate) -> Void)?
    
    /// open choose categories controller
    var openCategories: (() -> Void)?
    
    init(_ service: PlaceService) {
        self.placeService = service
    }
    
    /// get info about for current location
    func getInfoPlace(location: CLLocation, distance: CLLocationDistance) -> Observable<PlacesSections> {
        var selected: [Categories] = [.arts, .education, .fitness, .food, .hotel, .medical, .shopping, .travel]
        do {
            let realm = try Realm()
            let selectedCategories = realm.objects(FilterSelectedCategory.self)
            if !selectedCategories.isEmpty {
                selected = selectedCategories.map({ Categories(rawValue: $0.category)! })
            }
        } catch {
            print(error)
        }
        
        return placeService.getInfoAboutPlace(location, selected, distance)
            .asObservable().flatMap { (model) -> Observable<PlacesSections> in
                let sections = model.map({ $0.categories })
                let uniqueSections = sections.reduce([], { (acc: [[Categories]], element) in
                    var unique: [[Categories]]
                    let contains = acc.contains(where: { $0 == (element ?? []) })
                    if contains {
                        unique = acc
                    } else {
                        unique = acc + [(element ?? [])]
                    }
                    return unique
                }).sorted(by: { (itemOne, itemTwo) -> Bool in
                    return (itemOne.first?.title ?? "") < (itemTwo.first?.title ?? "")
                })
                
                var placesFilter: [[PlaceModel]] = []
                uniqueSections.forEach({ (section) in
                    let places = model.filter({ ($0.categories ?? []) == section })
                    placesFilter += [places]
                })
                return Observable.just(PlacesSections(placesFilter, uniqueSections))
        }
    }
}
