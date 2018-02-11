//
//  SettingsViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 24/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift

final class SettingsViewController: UIViewController {
    typealias Dependecies = HasSettingsViewModel
    
    fileprivate let viewModel: SettingsViewModel
    fileprivate let disposeBag = DisposeBag()
    
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
        tableView.register(SwitchSettingTableViewCell.self, forCellReuseIdentifier: SwitchSettingTableViewCell.cellIdentifier)
    }
    
    func setUpAlertView(title: String, description: String, action: @escaping () -> Void) {
        let alert = UIAlertController(title: title,
                                      message: description,
                                      preferredStyle: UIAlertControllerStyle.alert)
        let clear = UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            action()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(clear)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
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
        case .favoriteNotify(let title, let enable, let image, let color):
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingTableViewCell.cellIdentifier,
                                                     for: indexPath) as? SwitchSettingTableViewCell ?? SwitchSettingTableViewCell()
            
            cell.title = title
            cell.img = image
            cell.imageColor = color
            cell.enable = enable
            
            cell.switchButton.rx.value.asObservable()
                .subscribe(onNext: { [unowned self] (isOn) in
                    self.viewModel.disabledNotice(isOn)
                }, onError: { (error) in
                    print(error)
                }).disposed(by: disposeBag)
            
            return cell
        case .facebookLogin:
            let cell = tableView.dequeueReusableCell(withIdentifier: FCButtonLoginTableViewCell.cellIdentifier,
                                                     for: indexPath) as? FCButtonLoginTableViewCell ?? FCButtonLoginTableViewCell()
            return cell
        case .clearFavorites(let title, _, let image, let color),
             .clearHistorySearch(let title, _, let image, let color):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: StandardSettingTableViewCell.cellIdentifier,
                                                     for: indexPath) as? StandardSettingTableViewCell ?? StandardSettingTableViewCell()
            
            cell.title = title
            cell.img = image
            cell.imageColor = color
            return cell
        case .listFavoritesNoticy(let title, _, let image, let color),
             .showSearchHistory(let title, let image, let color):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: StandardSettingTableViewCell.cellIdentifier,
                                                     for: indexPath) as? StandardSettingTableViewCell ?? StandardSettingTableViewCell()
            
            cell.title = title
            cell.img = image
            cell.imageColor = color
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let typeCell = viewModel.items[indexPath.section].sectionObjects[indexPath.row]
        
        switch typeCell {
        case .clearFavorites(let title, let description, _, _):
            setUpAlertView(title: title, description: description, action: { [unowned self] in
                self.viewModel.deleteAllFavorites()
            })
        case .clearHistorySearch(let title, let description, _, _):
            setUpAlertView(title: title, description: description, action: { [unowned self] in
                self.viewModel.deleteSearchHistory()
            })
        case .showSearchHistory:
            viewModel.openSearchHistory()
        case .listFavoritesNoticy:
            viewModel.openListFavoritesNotice()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let typeCell = viewModel.items[indexPath.section].sectionObjects[indexPath.row]
        
        switch typeCell {
        case .facebookLogin,
             .clearFavorites,
             .clearHistorySearch,
             .showSearchHistory,
             .favoriteNotify,
             .listFavoritesNoticy:
            return 50.0
        }
    }
}
