//
//  ResultSearchViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 02/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ResultSearchViewController: UIViewController {

    let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(64.0)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        updateViewConstraints()
    }
    
    func updateTable() {
        tableView.reloadData()
    }
}
