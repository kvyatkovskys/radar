//
//  AppInjections.swift
//  Circle
//
//  Created by Kviatkovskii on 09/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import Kingfisher

protocol HasRouter {
    var router: Router { get }
}

protocol HasKingfisher {
    var kingfisherOptions: KingfisherOptionsInfo { get }
}

// MARK: MainViewController
protocol HasPlaceViewModel {
    var viewModel: PlaceViewModel { get }
}

/// container dependecies injection's for main tab controller
struct PlacesViewDependecies: HasKingfisher, HasPlaceViewModel {
    let kingfisherOptions: KingfisherOptionsInfo
    let viewModel: PlaceViewModel
    
    init(_ kingfisherOptions: KingfisherOptionsInfo, _ viewModel: PlaceViewModel) {
        self.kingfisherOptions = kingfisherOptions
        self.viewModel = viewModel
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

// MARK: DetailPlaceViewController
protocol HasDetailPlaceViewModel {
    var viewModel: DetailPlaceViewModel { get }
}

/// container dependecies injection's for detail place controller
struct DetailPlaceDependecies: HasDetailPlaceViewModel, HasKingfisher {
    let viewModel: DetailPlaceViewModel
    let kingfisherOptions: KingfisherOptionsInfo
    
    init(_ viewModel: DetailPlaceViewModel, _ kingfisherOptions: KingfisherOptionsInfo) {
        self.viewModel = viewModel
        self.kingfisherOptions = kingfisherOptions
    }
}
