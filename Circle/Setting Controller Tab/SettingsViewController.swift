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
        tableView.register(StandardSettingTableViewCell.self, forCellReuseIdentifier: StandardSettingTableViewCell.cellIdentifier)
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
        case .clearFavorites(let title, let image, let color):
            let cell = tableView.dequeueReusableCell(withIdentifier: StandardSettingTableViewCell.cellIdentifier,
                                                     for: indexPath) as? StandardSettingTableViewCell ?? StandardSettingTableViewCell()
            
            cell.title = title
            cell.img = image
            cell.imageColor = color
            return cell
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let typeCell = viewModel.items[indexPath.section].sectionObjects[indexPath.row]
        
        switch typeCell {
        case .clearFavorites:
            let alert = UIAlertController(title: "Clear Favorites",
                                          message: "Are you sure you want to clear all items in your Favorites?",
                                          preferredStyle: UIAlertControllerStyle.alert)
            let clear = UIAlertAction(title: "Clear", style: .destructive, handler: { [unowned self] _ in
                self.viewModel.deleteAllFavorites()
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(clear)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let typeCell = viewModel.items[indexPath.section].sectionObjects[indexPath.row]
        
        switch typeCell {
        case .facebookLogin, .clearFavorites: return 50.0
        }
    }
}
