//
//  PlaceViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 01/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift

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
    var openFilter: ((_ delegate: FilterPlacesDelegate) -> Void)?
    
    init(_ service: PlaceService) {
        self.placeService = service
    }
    
    /// get info about for current location
    func getInfoPlace(location: CLLocation,
                      categories: [Categories] = [.arts, .education, .fitness, .food, .hotel, .medical, .shopping, .travel],
                      distance: CLLocationDistance) -> Observable<PlacesSections> {
        return placeService.getInfoAboutPlace(location, categories, distance)
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
