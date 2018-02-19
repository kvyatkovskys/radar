//
//  KSTableView.swift
//  Circle
//
//  Created by Kviatkovskii on 17/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

let heightTableCell: CGFloat = 250.0

final class KSTableView: UITableView {
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.backgroundColor = UIColor.lightGrayTable
        self.separatorInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        self.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
