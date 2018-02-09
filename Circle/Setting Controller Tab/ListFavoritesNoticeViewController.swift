//
//  ListFavoritesNoticeViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 09/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListFavoritesNoticeViewController: UIViewController {
    typealias Dependecies = HasListFavoritesNoticeViewModel
    
    fileprivate let viewModel: ListFavoritesNoticeViewModel
    
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
            make.top.equalToSuperview().offset(64.0)
            make.left.bottom.right.equalToSuperview()
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

        navigationItem.title = "Search History"
        navigationItem.leftBarButtonItem = leftBarButton
        
        view.addSubview(tableView)
        updateViewConstraints()
        
        tableView.register(ListFavoritesNoticeTableViewCell.self, forCellReuseIdentifier: ListFavoritesNoticeTableViewCell.cellIdentifier)
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
        
        cell.title = item        
        return cell
    }
}

extension ListFavoritesNoticeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
