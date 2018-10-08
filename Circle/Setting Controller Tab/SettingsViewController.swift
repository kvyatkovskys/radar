//
//  SettingsViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 24/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift
import Swinject

final class SettingsViewController: UIViewController {
    
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
    
    init(_ container: Container) {
        self.viewModel = container.resolve(SettingsViewModel.self)!
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        updateViewConstraints()
        
        tableView.registerCellClasses(cellType: SettingRowType.self) { (item) -> UITableViewCell.Type in
            switch item {
            case .facebookLogin:
                return FCButtonLoginTableViewCell.self
            case .favoriteNotify:
                return SwitchSettingTableViewCell.self
            case .listFavoritesNoticy,
                 .clearFavorites,
                 .clearHistorySearch,
                 .showSearchHistory,
                 .openSettings:
                return StandardSettingTableViewCell.self
            }
        }
    }
    
    func setUpAlertView(title: String, description: String, action: @escaping () -> Void) {
        let alert = UIAlertController(title: title,
                                      message: description,
                                      preferredStyle: .actionSheet)
        let clear = UIAlertAction(title: NSLocalizedString("clear", comment: "Title for clear button"),
                                  style: .destructive,
                                  handler: { _ in
            action()
        })
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: "Title for cancel button"),
                                   style: .cancel,
                                   handler: nil)
        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: typeCell.rawValue,
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
            let cell = tableView.dequeueReusableCell(withIdentifier: typeCell.rawValue,
                                                     for: indexPath) as? FCButtonLoginTableViewCell ?? FCButtonLoginTableViewCell()
            return cell
        case .clearFavorites(let title, _, let image, let color),
             .clearHistorySearch(let title, _, let image, let color),
             .openSettings(let title, let image, let color):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: typeCell.rawValue,
                                                     for: indexPath) as? StandardSettingTableViewCell ?? StandardSettingTableViewCell()
            
            cell.title = title
            cell.img = image
            cell.imageColor = color
            return cell
        case .listFavoritesNoticy(let title, _, let image, let color),
             .showSearchHistory(let title, let image, let color):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: typeCell.rawValue,
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
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        guard  indexPath.row != lastRowIndex && indexPath.section != lastSectionIndex else {
            tableView.separatorColor = .lightGray
            return
        }
        tableView.separatorColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if viewModel.items[section].sectionName.title == "" {
            return 0
        }
        return 35.0
    }
    
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
        case .openSettings:
            viewModel.openSettingsPhone()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let typeCell = viewModel.items[indexPath.section].sectionObjects[indexPath.row]
        
        switch typeCell {
        case .clearFavorites,
             .clearHistorySearch,
             .showSearchHistory,
             .favoriteNotify,
             .listFavoritesNoticy,
             .openSettings:
            return 50.0
        case .facebookLogin:
            return 60.0
        }
    }
}
