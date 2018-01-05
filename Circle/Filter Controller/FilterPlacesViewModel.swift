//
//  FilterPlacesViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 03/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

enum TypeFilter: Int {
    case distance, categories
}

struct FilterViewModel {
    let items: [FilterModel] = ["Distance", "Categories"].map({ FilterModel(title: $0) })
    var chooseFilter: (() -> Void)?
}

struct FilterDistanceViewModel {
    let defaultDistance: Double = UserDefaults.standard.double(forKey: "FilterDistance") == 0.0 ? 1000.0 : UserDefaults.standard.double(forKey: "FilterDistance")
    let items: [FilterDistanceModel] = [FilterDistanceModel(title: "500 meters", value: 500.0),
                                        FilterDistanceModel(title: "1000 meters", value: 1000.0),
                                        FilterDistanceModel(title: "1500 meters", value: 1500.0),
                                        FilterDistanceModel(title: "2000 meters", value: 2000.0),
                                        FilterDistanceModel(title: "2500 meters", value: 2500.0)]
}
