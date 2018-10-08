//
//  PlaceViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 01/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import Kingfisher

enum TypeView: Int {
    case table, map
}

struct PlaceViewModel: Place {
    fileprivate let disposeBag = DisposeBag()
    
    let placeService: PlaceService
    /// open filter controller
    var openFilter: (() -> Void) = {}
    /// open map controller
    var openMap: (([PlaceModel], CLLocation?) -> Void) = { _, _ in }
    /// open detail place controller
    var openDetailPlace: ((PlaceModel, FavoritesViewModel) -> Void) = { _, _ in }
    /// reload places on map
    var reloadMap: (([PlaceModel], CLLocation?) -> Void) = { _, _ in }
    
    var places: BehaviorRelay<PlaceDataModel> = BehaviorRelay<PlaceDataModel>(value: PlaceDataModel(data: [], next: nil))
    var heightHeader: CGFloat = 100.0
    var searchForMinDistance: Bool = false
    let kingfisherOptions: KingfisherOptionsInfo
    var locationService: LocationService
    var userLocation: CLLocation?
    var typeView: TypeView = .table
    
    init(_ service: PlaceService, kingfisher: KingfisherOptionsInfo, locationService: LocationService) {
        self.placeService = service
        self.kingfisherOptions = kingfisher
        self.locationService = locationService
    }
    
    /// load more places
    func getMorePlaces(url: URL) {
        placeService.loadMorePlaces(url: url)
            .asObservable()
            .subscribe(onNext: { (newPlaces) in
                var oldPlaces = self.places.value
                oldPlaces.data += newPlaces.data
                oldPlaces.next = newPlaces.next
                self.places.accept(oldPlaces)
            })
            .disposed(by: disposeBag)
    }
    
    /// get info about for current location
    func getPlaces(location: CLLocation?, distance: CLLocationDistance, searchTerm: String? = nil) {
        var categories = PlaceSetting().allCategories
        
        if searchTerm == nil {
            do {
                let realm = try Realm()
                let selectedCategories = realm.objects(FilterSelectedCategory.self)
                if !selectedCategories.isEmpty {
                    categories = selectedCategories.map({ Categories(rawValue: $0.category)! })
                }
            } catch {
                print(error)
            }
        }
        
        placeService.loadPlaces(location, categories, distance, searchTerm)
            .asObservable()
            .bind(to: places)
            .disposed(by: disposeBag)
    }
}

protocol Place {
    /// open filter controller
    var openFilter: (() -> Void) { get set }
    /// open map controller
    var openMap: (([PlaceModel], CLLocation?) -> Void) { get set }
    /// open detail place controller
    var openDetailPlace: ((PlaceModel, FavoritesViewModel) -> Void) { get set }
    /// reload places on map
    var reloadMap: (([PlaceModel], CLLocation?) -> Void) { get set }
    
    var typeView: TypeView { get }
    var placeService: PlaceService { get }
    var places: BehaviorRelay<PlaceDataModel> { get }
    var heightHeader: CGFloat { get }
    var searchForMinDistance: Bool { get }
    var kingfisherOptions: KingfisherOptionsInfo { get }
    var locationService: LocationService { get }
    var userLocation: CLLocation? { get }
}
