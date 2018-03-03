//
//  SearchHistoryViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 05/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class SearchHistoryViewController: UIViewController {
    typealias Dependecies = HasSearchHistoryViewModel
    
    fileprivate let viewModel: SearchHistoryViewModel
    
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
        self.viewModel = dependecies.searchHistoryViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("searchHistory", comment: "The title for navigatio bar with a search of history")
        navigationItem.leftBarButtonItem = leftBarButton
        
        view.addSubview(tableView)
        updateViewConstraints()
        
        tableView.register(SearchHistoryTableViewCell.self, forCellReuseIdentifier: SearchHistoryTableViewCell.cellIdentifier)
    }
    
    @objc func closeController() {
        dismiss(animated: true, completion: nil)
    }
}

extension SearchHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryTableViewCell.cellIdentifier,
                                                 for: indexPath) as? SearchHistoryTableViewCell ?? SearchHistoryTableViewCell()
        
        cell.title = item.query
        cell.subTitle = item.date
        
        return cell
    }
}

extension SearchHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
