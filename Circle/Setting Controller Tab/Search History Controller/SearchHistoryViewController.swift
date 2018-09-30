//
//  SearchHistoryViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 05/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift
import Swinject

final class SearchHistoryViewController: UIViewController {
    
    fileprivate let viewModel: SearchHistoryViewModel
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView(frame: CGRect.zero)
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
    
    init(_ container: Container) {
        self.viewModel = container.resolve(SearchHistoryViewModel.self)!
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
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.dataSource.asObservable()
        .bind(to: tableView.rx
            .items(cellIdentifier: SearchHistoryTableViewCell.cellIdentifier, cellType: SearchHistoryTableViewCell.self)) { (_, item, cell) in
                cell.title = item.query
                cell.subTitle = item.date
        }
        .disposed(by: disposeBag)
    }
    
    @objc func closeController() {
        dismiss(animated: true, completion: nil)
    }
}

extension SearchHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
