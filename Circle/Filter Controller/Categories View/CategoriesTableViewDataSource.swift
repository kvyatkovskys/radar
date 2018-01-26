//
//  CategoriesTableViewDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 09/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class CategoriesTableViewDataSource: NSObject {
    fileprivate let selectIndex: NSMutableIndexSet
    fileprivate let items: [FilterCategoriesModel]
    
    init(_ tableView: UITableView, _ viewModel: FilterCategoriesViewModel) {
        self.selectIndex = viewModel.selectIndexes
        self.items = viewModel.items
        super.init()
        tableView.dataSource = self
        tableView.separatorInset.left = 0.0
    }
}

extension CategoriesTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesTableViewCell.cellIdentifier,
                                                 for: indexPath) as? CategoriesTableViewCell ?? CategoriesTableViewCell()
        
        cell.title = items[indexPath.row].category.title
        cell.type = items[indexPath.row].category
        cell.select = selectIndex.contains(indexPath.row)
        
        return cell
    }
}
