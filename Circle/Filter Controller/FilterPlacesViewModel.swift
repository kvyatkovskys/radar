//
//  FilterPlacesViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 03/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift

protocol CategoriesProtocol {
    var selectIndexes: NSMutableIndexSet { get set }
    func addIndex(_ index: IndexPath)
    func deletedIndex(_ index: IndexPath)
}

enum TypeFilter: Int {
    case distance, categories, rating
}

struct FilterViewModel {
    let items: [FilterModel] = ["Distance", "Categories"].map({ FilterModel(title: $0) })
    var chooseFilter: (() -> Void)?
}

struct FilterDistanceViewModel {
    let defaultDistance: Double
 
    init() {
        var selectedDistance: Double = 0.0
        do {
            let realm = try Realm()
            selectedDistance = realm.objects(FilterSelectedDistance.self).first?.distance ?? 1000.0
        } catch {
            print(error)
        }
        self.defaultDistance = selectedDistance
    }
    
    func setNewDistance(value: Double) {
        do {
            let realm = try Realm()
            let oldDistance = realm.objects(FilterSelectedDistance.self).first
            try realm.write {
                guard let oldDistance = oldDistance else {
                    let selectedDistance = FilterSelectedDistance()
                    selectedDistance.distance = value
                    realm.add(selectedDistance)
                    return
                }
                oldDistance.distance = value
            }
        } catch {
            print(error)
        }
    }
}

struct FilterCategoriesViewModel: CategoriesProtocol {
    fileprivate let sortedItems: [FilterCategoriesModel] = [.arts,
                                                            .education,
                                                            .fitness,
                                                            .food,
                                                            .hotel,
                                                            .shopping,
                                                            .medical,
                                                            .travel].map({ FilterCategoriesModel(category: $0) })
    let items: [FilterCategoriesModel]
    var selectIndexes: NSMutableIndexSet
    
    init() {
        self.items = sortedItems.sorted(by: { (first, second) -> Bool in
            return first.category.title < second.category.title
        })
        
        let selected = NSMutableIndexSet()
        do {
            let realm = try Realm()
            let selectedIndex = realm.objects(FilterSelectedCategory.self)
            selectedIndex.forEach({ (item) in
                selected.add(item.index)
            })
        } catch {
            print(error)
        }
        self.selectIndexes = selected
    }
    
    func addIndex(_ index: IndexPath) {
        selectIndexes.add(index.row)
        
        let selectedCategory = FilterSelectedCategory()
        selectedCategory.index = index.row
        selectedCategory.category = items[index.row].category.rawValue
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(selectedCategory)
            }
        } catch {
            print(error)
        }
    }
    
    func deletedIndex(_ index: IndexPath) {
        selectIndexes.remove(index.row)
        
        do {
            let realm = try Realm()
            let deletedIndex = realm.objects(FilterSelectedCategory.self).filter("index = \(index.row)")
            try realm.write {
                realm.delete(deletedIndex)
            }
        } catch {
            print(error)
        }
    }
}
