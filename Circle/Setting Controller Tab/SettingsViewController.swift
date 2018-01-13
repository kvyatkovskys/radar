//
//  SettingsViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 24/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {
    typealias Dependecies = HasSettingsViewModel
    
    fileprivate let viewModel: SettingsViewModel
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    init(_ dependecies: Dependecies) {
        self.viewModel = dependecies.viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        updateViewConstraints()
        
        tableView.register(FCButtonLoginTableViewCell.self, forCellReuseIdentifier: FCButtonLoginTableViewCell.cellIdentifier)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items[section].sectionObjects.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.items[section].sectionName.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let typeCell = viewModel.items[indexPath.section].sectionObjects[indexPath.row]
        
        switch typeCell {
        case .facebookLogin:
            let cell = tableView.dequeueReusableCell(withIdentifier: FCButtonLoginTableViewCell.cellIdentifier,
                                                     for: indexPath) as? FCButtonLoginTableViewCell ?? FCButtonLoginTableViewCell()
            
            return cell
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let typeCell = viewModel.items[indexPath.section].sectionObjects[indexPath.row]
        
        switch typeCell {
        case .facebookLogin:
            return 50.0
        }
    }
}
