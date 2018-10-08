//
//  TableView+Extension.swift
//  Circle
//
//  Created by Sergei Kviatkovskii on 05/10/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

extension UITableView {
    func registerCellClasses<T: CaseIterable & RawRepresentable>(cellType: T.Type, resolver: (T) -> UITableViewCell.Type) where T.RawValue == String {
        cellType.allCases.forEach { (item) in
            register(resolver(item), forCellReuseIdentifier: item.rawValue)
        }
    }
}
