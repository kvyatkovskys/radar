//
//  KSTableView.swift
//  Circle
//
//  Created by Kviatkovskii on 17/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

let heightTableCell: CGFloat = 280.0

final class KSTableView: UITableView {
    let refresh = UIRefreshControl()
    
    /// Enabled refresh for table view
    var isEnabledRefresh: Bool = false {
        didSet {
            guard isEnabledRefresh else { return }
            self.refreshControl = refresh
        }
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.backgroundColor = .white
        self.separatorInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        self.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
