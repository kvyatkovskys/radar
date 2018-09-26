//
//  ListFavoritesNoticeViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 09/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RealmSwift
import Swinject
import RxSwift

final class ListFavoritesNoticeViewController: UIViewController {
    
    fileprivate var viewModel: ListFavoritesNoticeViewModel
    fileprivate var notificationToken: NotificationToken?
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
        self.viewModel = container.resolve(ListFavoritesNoticeViewModel.self)!
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
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.dataSource.asObservable()
            .bind(to: tableView.rx
                .items(cellIdentifier: ListFavoritesNoticeTableViewCell.cellIdentifier, cellType: ListFavoritesNoticeTableViewCell.self)) { (_, item, cell) in
                    cell.title = item.title
                    cell.checkmark = item.notify
        }
        .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Favorites.self)
            .subscribe(onNext: { [unowned self] (item) in
                self.viewModel.selectNotify(item)
            }).disposed(by: disposeBag)
        
        do {
            let realm = try Realm()
            let favorites = realm.objects(Favorites.self)
            
            notificationToken = favorites.observe({ [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    break
                case .update(let favorite, _, _, _):
                    self.viewModel.dataSource.accept(favorite.sorted(byKeyPath: "date", ascending: false).map({ $0 }))
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

extension ListFavoritesNoticeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}
