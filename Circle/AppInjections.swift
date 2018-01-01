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
struct MainViewDependecies: HasRouter, HasKingfisher, HasPlaceViewModel {
    let router: Router
    let kingfisherOptions: KingfisherOptionsInfo
    let viewModel: PlaceViewModel
    
    init(_ router: Router, _ kingfisherOptions: KingfisherOptionsInfo, _ viewModel: PlaceViewModel) {
        self.router = router
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
