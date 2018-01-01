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

/// container dependecies injection's for main tab controller
struct MainViewDependecies: HasRouter, HasKingfisher {
    let router: Router
    let kingfisherOptions: KingfisherOptionsInfo
    
    init(_ router: Router, _ kingfisherOptions: KingfisherOptionsInfo) {
        self.router = router
        self.kingfisherOptions = kingfisherOptions
    }
}

/// container dependecies injection's for settings tab controller
struct SettingsViewDependecies: HasRouter {
    let router: Router
    
    init(_ router: Router) {
        self.router = router
    }
}
