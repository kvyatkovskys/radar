//
//  PlaceViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 01/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift

struct PlaceViewModel {
    fileprivate let placeService: PlaceService
    
    init(_ service: PlaceService) {
        self.placeService = service
    }
    
    /// get info about for current location
    func getInfoPlace(location: CLLocation,
                      categories: [Categories] = [.arts, .education, .fitness, .food, .hotel, .medical, .shopping, .travel],
                      distance: CLLocationDistance = 1000) -> Observable<[PlaceModel]> {
        return placeService.getInfoAboutPlace(location, categories, distance).asObservable().flatMap { (model) -> Observable<[PlaceModel]> in
            return Observable.just(model)
        }
    }
}
