//
//  SearchHistoryViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 05/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa

struct SearchHistoryViewModel {
    typealias SearchHistory = (query: String?, date: String?)
    
    let dataSource: BehaviorRelay<[SearchHistory]> = {
        var searchHistory: [SearchHistory] = []
        
        do {
            let realm = try Realm()
            let search = realm.objects(Search.self).filter("query != ''")
            searchHistory = search.flatMap({ (item) -> [SearchHistory] in
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .short
                return [SearchHistory(item.query, dateFormatter.string(from: item.date))]
            })
        } catch {
            print(error)
        }
        
        return BehaviorRelay(value: searchHistory.sorted(by: { $0.date! > $1.date! }))
    }()
}
