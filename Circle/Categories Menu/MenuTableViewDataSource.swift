//
//  MenuTableViewDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 01.06.17.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit

final class MenuTableViewDataSource: NSObject {
    fileprivate let viewModel: MenuViewModel
    
    init(tableView: UITableView, viewModel: MenuViewModel) {
        self.viewModel = viewModel
        super.init()
        tableView.dataSource = self
    }
}

extension MenuTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = viewModel.items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.cellIdentifier,
                                                 for: indexPath) as? MenuTableViewCell ?? MenuTableViewCell()
        cell.title = category.title
        return cell
    }
}
