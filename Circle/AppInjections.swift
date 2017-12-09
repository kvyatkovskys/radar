//
//  AppInjections.swift
//  Circle
//
//  Created by Kviatkovskii on 09/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation

protocol HasRouter {
    var router: Router { get }
}

struct MainViewDependecies: HasRouter {
    let router: Router
    
    init(_ router: Router) {
        self.router = router
    }
}
