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
    let items: [FilterModel] = [NSLocalizedString("distance", comment: "Title for filter of distance"),
                                NSLocalizedString("categories", comment: "Title for filter of category")].map({ FilterModel(title: $0) })
    var chooseFilter: (() -> Void)?
}

struct FilterDistanceViewModel {
    let defaultDistance: Double
    let searchForMinDistance: Bool
 
    init() {
        var selectedDistance: Double = 0.0
        var minDistance: Bool = false
        do {
            let realm = try Realm()
            let filterDistance = realm.objects(FilterSelectedDistance.self).first
            selectedDistance = filterDistance?.distance ?? 1000.0
            minDistance = filterDistance?.searchForMinDistance ?? false
        } catch {
            print(error)
        }
        self.defaultDistance = selectedDistance
        self.searchForMinDistance = minDistance
    }
    
    func setMinDistance(value: Bool) {
        do {
            let realm = try Realm()
            let oldMinDistance = realm.objects(FilterSelectedDistance.self).first
            try realm.write {
                guard let minDistance = oldMinDistance else {
                    let newMinDistance = FilterSelectedDistance()
                    newMinDistance.searchForMinDistance = value
                    realm.add(newMinDistance)
                    return
                }
                minDistance.searchForMinDistance = value
            }
        } catch {
            print(error)
        }
    }
    
    func setNewDistance(value: Double) {
        do {
            let realm = try Realm()
            let oldDistance = realm.objects(FilterSelectedDistance.self).first
            try realm.write {
                guard let oldDistance = oldDistance else {
                    let newDistance = FilterSelectedDistance()
                    newDistance.distance = value
                    realm.add(newDistance)
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
