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
