//
//  CategoriesTableViewDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 09/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class CategoriesTableViewDelegate: NSObject {
    init(_ tableView: UITableView) {
        super.init()
        tableView.delegate = self
    }
}

extension CategoriesTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
}
