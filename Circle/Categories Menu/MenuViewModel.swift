//
//  MenuViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 01.06.17.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import UIKit

protocol MenuViewModelProtocol {
    var setIndex: NSMutableIndexSet { get set }
    func addIndexSet(index: IndexPath)
}

struct MenuViewModel {
    var items: [Categories]
    var setIndex: NSMutableIndexSet
    
    init(items: [Categories] = [], setIndex: NSMutableIndexSet = NSMutableIndexSet(index: 0)) {
        self.items = items
        self.setIndex = setIndex
    }
    
    func addIndexSet(index: IndexPath) {
        setIndex.removeAllIndexes()
        setIndex.add(index.row)
    }
}

extension MenuViewModel {
    func getIndexArticle(_ article: Categories) -> Int {
        var select = 0
        for case let Article in items.enumerated() where Article.element == article {
            select = Article.offset
        }
        return select
    }
}
