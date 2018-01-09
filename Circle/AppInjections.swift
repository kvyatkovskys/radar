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
/// container dependecies injection's for settings tab controller
struct SettingsViewDependecies: HasRouter {
    let router: Router
    
    init(_ router: Router) {
        self.router = router
    }
}

// MARK: CategoriesViewController
protocol HasGategoriesViewModel {
    var viewModel: CategoriesViewModel { get }
}

/// container dependecies injection's for categories view
struct CategoriesViewDependecies: HasGategoriesViewModel {
    let viewModel: CategoriesViewModel
    
    init(_ viewModel: CategoriesViewModel) {
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
