//
//  CategoriesViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 02/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift

struct CategoriesViewModel {
    let categories: Observable<[Categories]>
    
    init(_ categories: [Categories]) {
        self.categories = Observable.just(categories)
    }
}
