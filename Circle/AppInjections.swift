//
//  AppInjections.swift
//  Circle
//
//  Created by Kviatkovskii on 09/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import Kingfisher

protocol HasOpenGraphService {
    var service: OpenGraphService { get }
}

protocol HasKingfisher {
    var kingfisherOptions: KingfisherOptionsInfo { get }
}

protocol HasLocationService {
    var locationService: LocationService { get }
}

// MARK: MainViewController
protocol HasPlaceViewModel {
    var viewModel: PlaceViewModel { get }
}

/// container dependecies injection's for main tab controller
struct PlacesViewDependecies: HasKingfisher, HasPlaceViewModel, HasLocationService {
    let kingfisherOptions: KingfisherOptionsInfo
    let viewModel: PlaceViewModel
    let locationService: LocationService
    
    init(_ kingfisherOptions: KingfisherOptionsInfo, _ viewModel: PlaceViewModel, _ locationService: LocationService) {
        self.kingfisherOptions = kingfisherOptions
        self.viewModel = viewModel
        self.locationService = locationService
    }
}

// MARK: SettingsViewController
protocol HasSettingsViewModel {
    var viewModel: SettingsViewModel { get }
}
/// container dependecies injection's for settings tab controller
struct SettingsViewDependecies: HasSettingsViewModel {
    let viewModel: SettingsViewModel
    
    init(_ viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: FilterPlacesViewController
protocol HasFilterPlacesViewModel {
    var viewModel: FilterViewModel { get }
    var viewModelDistance: FilterDistanceViewModel { get }
    var viewModelCategories: FilterCategoriesViewModel { get }
}

//swiftlint:disable class_delegate_protocol
protocol HasFilterPlacesDelegate {
    weak var delegate: FilterPlacesDelegate? { get }
}

/// container dependecies injection's for filter view
struct FilterPlacesDependecies: HasFilterPlacesViewModel, HasFilterPlacesDelegate {
    let viewModel: FilterViewModel
    let viewModelDistance: FilterDistanceViewModel
    let viewModelCategories: FilterCategoriesViewModel
    
    weak var delegate: FilterPlacesDelegate?
    
    init(_ viewModel: FilterViewModel, _ viewModelDistance: FilterDistanceViewModel, _ viewModelCategories: FilterCategoriesViewModel, _ delegate: FilterPlacesDelegate?) {
        self.viewModel = viewModel
        self.viewModelDistance = viewModelDistance
        self.viewModelCategories = viewModelCategories
        self.delegate = delegate
    }
}

protocol HasMapModel {
    var places: [Places] { get }
    var location: CLLocation? { get }
}

/// container dependecies injection's for map controller
struct MapDependecies: HasMapModel {
    let places: [Places]
    let location: CLLocation?
    
    init(_ places: [Places], _ location: CLLocation?) {
        self.places = places
        self.location = location
    }
}

protocol HasFavoritesViewModel {
    var favoritesViewModel: FavoritesViewModel { get }
}

struct FavoritesDependencies: HasFavoritesViewModel, HasKingfisher {
    let favoritesViewModel: FavoritesViewModel
    let kingfisherOptions: KingfisherOptionsInfo
    
    init(_ favoritesViewModel: FavoritesViewModel, _ kingfisherOptions: KingfisherOptionsInfo) {
        self.favoritesViewModel = favoritesViewModel
        self.kingfisherOptions = kingfisherOptions
    }
}

// MARK: DetailPlaceViewController
protocol HasDetailPlaceViewModel {
    var detailViewModel: DetailPlaceViewModel { get }
}

/// container dependecies injection's for detail place controller
struct DetailPlaceDependecies: HasDetailPlaceViewModel, HasKingfisher, HasOpenGraphService, HasFavoritesViewModel {
    let detailViewModel: DetailPlaceViewModel
    let favoritesViewModel: FavoritesViewModel
    let kingfisherOptions: KingfisherOptionsInfo
    let service: OpenGraphService
    
    init(_ detailViewModel: DetailPlaceViewModel, _ favoritesViewModel: FavoritesViewModel, _ kingfisherOptions: KingfisherOptionsInfo, _ service: OpenGraphService) {
        self.detailViewModel = detailViewModel
        self.favoritesViewModel = favoritesViewModel
        self.kingfisherOptions = kingfisherOptions
        self.service = service
    }
}

protocol HasSearchViewModel {
    var searchViewModel: SearchViewModel { get }
}

struct SeacrhPlaceDependecies: HasSearchViewModel, HasKingfisher {
    let searchViewModel: SearchViewModel
    let kingfisherOptions: KingfisherOptionsInfo
    
    init(_ searchViewModel: SearchViewModel, _ kingfisherOptions: KingfisherOptionsInfo) {
        self.searchViewModel = searchViewModel
        self.kingfisherOptions = kingfisherOptions
    }
}

struct ResultSearchDependecies: HasKingfisher {
    let kingfisherOptions: KingfisherOptionsInfo
    
    init(_ kingfisherOptions: KingfisherOptionsInfo) {
        self.kingfisherOptions = kingfisherOptions
    }
}

protocol HasSearchHistoryViewModel {
    var searchHistoryViewModel: SearchHistoryViewModel { get }
}

struct SearchHistoryDependecies: HasSearchHistoryViewModel {
    let searchHistoryViewModel: SearchHistoryViewModel
    
    init(_ searchHistoryViewModel: SearchHistoryViewModel) {
        self.searchHistoryViewModel = searchHistoryViewModel
    }
}
