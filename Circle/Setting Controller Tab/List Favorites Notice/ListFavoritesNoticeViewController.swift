//
//  ListFavoritesNoticeViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 09/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RealmSwift

final class ListFavoritesNoticeViewController: UIViewController {
    typealias Dependecies = HasListFavoritesNoticeViewModel
    
    fileprivate var viewModel: ListFavoritesNoticeViewModel
    fileprivate var notificationToken: NotificationToken?
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    fileprivate lazy var leftBarButton: UIBarButtonItem = {
        let closeImage = UIImage(named: "ic_close")!.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: closeImage, style: .done, target: self, action: #selector(closeController))
        button.tintColor = .white
        return button
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    init(_ dependecies: Dependecies) {
        self.viewModel = dependecies.listFavoritesNoticeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("listFavorites", comment: "The title for navigation bar with a list of favorites")
        navigationItem.leftBarButtonItem = leftBarButton
        
        view.addSubview(tableView)
        updateViewConstraints()
        
        tableView.register(ListFavoritesNoticeTableViewCell.self, forCellReuseIdentifier: ListFavoritesNoticeTableViewCell.cellIdentifier)
        
        do {
            let realm = try Realm()
            let favorites = realm.objects(Favorites.self)
            
            notificationToken = favorites.observe({ [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    break
                case .update(let favorite, _, _, _):
                    self.viewModel.dataSource = favorite.sorted(byKeyPath: "date", ascending: false).map({ $0 })
                    self.tableView.reloadData()
                case .error(let error):
                    fatalError("\(error)")
                }
            })
        } catch {
            print(error)
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }

    @objc func closeController() {
        dismiss(animated: true, completion: nil)
    }
}

extension ListFavoritesNoticeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ListFavoritesNoticeTableViewCell.cellIdentifier,
                                                 for: indexPath) as? ListFavoritesNoticeTableViewCell ?? ListFavoritesNoticeTableViewCell()
        
        cell.title = item.title
        cell.checkmark = item.notify
        return cell
    }
}

extension ListFavoritesNoticeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = viewModel.dataSource[indexPath.row]
        viewModel.selectNotify(item)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
