//
//  MenuTableViewDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 01.06.17.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit

protocol MenuTableDelegate: class {
    func chooseCategory(category: Categories)
}

final class MenuTableViewDelegate: NSObject {
    fileprivate var viewModel: MenuViewModel
    fileprivate weak var delegate: MenuTableDelegate?
    
    init(tableView: UITableView, viewModel: MenuViewModel, menuTableDelegate: MenuTableDelegate) {
        self.viewModel = viewModel
        self.delegate = menuTableDelegate
        super.init()
        tableView.delegate = self
    }
}

extension MenuTableViewDelegate: UITableViewDelegate {    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        viewModel.addIndexSet(index: indexPath)
        let category = viewModel.items[indexPath.row]
        delegate?.chooseCategory(category: category)
        tableView.reloadData()
    }
}
