//
//  CategoriesTableViewDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 09/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift

final class CategoriesTableViewDelegate: NSObject {
    fileprivate let viewModel: FilterCategoriesViewModel
    
    init(_ tableView: UITableView, _ viewModel: FilterCategoriesViewModel) {
        self.viewModel = viewModel
        super.init()
        tableView.delegate = self
    }
}

extension CategoriesTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if viewModel.selectIndexes.contains(indexPath.row) {
            viewModel.deletedIndex(indexPath)
        } else {
            viewModel.addIndex(indexPath)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
