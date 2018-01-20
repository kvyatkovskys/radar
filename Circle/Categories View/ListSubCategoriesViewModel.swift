//
//  ListSubCategoriesViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 20/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

struct ListSubCategoriesViewModel {
    let width: [CGFloat]
    let items: [String]
    let color: UIColor
    
    init(_ subCategories: [String], color: UIColor?) {
        self.width = subCategories.map({ $0.width(font: .systemFont(ofSize: 12.0), height: 20.0) + 15.0 })
        self.items = subCategories
        self.color = color ?? UIColor.clear
    }
}
