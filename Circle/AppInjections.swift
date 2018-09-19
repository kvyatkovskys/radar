//
//  AppInjections.swift
//  Circle
//
//  Created by Kviatkovskii on 09/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import Kingfisher

protocol HasKingfisher {
    var kingfisherOptions: KingfisherOptionsInfo { get }
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

/// container dependecies injection's for filter view
struct FilterPlacesDependecies: HasFilterPlacesViewModel {
    let viewModel: FilterViewModel
    let viewModelDistance: FilterDistanceViewModel
    let viewModelCategories: FilterCategoriesViewModel
    
    init(_ viewModel: FilterViewModel, _ viewModelDistance: FilterDistanceViewModel, _ viewModelCategories: FilterCategoriesViewModel) {
        self.viewModel = viewModel
        self.viewModelDistance = viewModelDistance
        self.viewModelCategories = viewModelCategories
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

protocol HasListFavoritesNoticeViewModel {
    var listFavoritesNoticeViewModel: ListFavoritesNoticeViewModel { get }
}

struct ListFavoritesNoticeDependecies: HasListFavoritesNoticeViewModel {
    let listFavoritesNoticeViewModel: ListFavoritesNoticeViewModel
    
    init(_ listFavoritesNoticeViewModel: ListFavoritesNoticeViewModel) {
        self.listFavoritesNoticeViewModel = listFavoritesNoticeViewModel
    }
}

protocol HasSourceImages {
    var images: [URL] { get }
    var startIndex: Int { get }
}

struct ListDeatilImagesDependecies: HasSourceImages {
    let images: [URL]
    let startIndex: Int
    
    init(_ images: [URL], _ startIndex: Int) {
        self.images = images
        self.startIndex = startIndex
    }
}
