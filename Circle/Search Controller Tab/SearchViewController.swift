//
//  SearchViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 27/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift

enum TitlesSearchType: Int {
    case address = 0
    case query = 1
    
    var title: String {
        switch self {
        case .address: return "Address"
        case .query: return "Query"
        }
    }
}

final class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {

    fileprivate let disposeBag = DisposeBag()
    fileprivate let resultController = ResultSearchViewController()
    
    fileprivate lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: resultController)
        controller.delegate = self
        controller.searchBar.placeholder = "Example: New York"
        controller.searchBar.delegate = self
        controller.searchBar.searchBarStyle = .default
        controller.searchBar.scopeButtonTitles = [TitlesSearchType.address.title, TitlesSearchType.query.title]
        controller.hidesNavigationBarDuringPresentation = true
        controller.dimsBackgroundDuringPresentation = true
        controller.searchBar.sizeToFit()
        
        if #available(iOS 11.0, *) {
            if let textfield = controller.searchBar.value(forKey: "searchField") as? UITextField {
                if let backgroundview = textfield.subviews.first {
                    // Background color
                    backgroundview.backgroundColor = .white
                    backgroundview.layer.cornerRadius = 10
                    backgroundview.clipsToBounds = true
                }
            }
            controller.searchBar.tintColor = UIColor.white
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .black
            self.definesPresentationContext = true
        }
        
        return controller
    }()
    
    fileprivate let tableView: UITableView = {
        let table = UITableView()
        //table.tableFooterView = UIView(frame: CGRect.zero)
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
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white,
                                                                            .font: UIFont.boldSystemFont(ofSize: 28)]
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.hidesSearchBarWhenScrolling = false
            navigationItem.searchController = searchController
        } else {
            navigationItem.titleView = searchController.searchBar
        }
        
        let searchQuery = searchController.searchBar.rx.text.orEmpty
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter({ !$0.isEmpty })
        
        let selectedIndex = searchController.searchBar.rx.selectedScopeButtonIndex.asObservable()
            .flatMap { Observable.just(TitlesSearchType(rawValue: $0)!) }
            .do(onNext: { (type) in
                switch type {
                case .address:
                    self.searchController.searchBar.placeholder = "Example: New York"
                case .query:
                    self.searchController.searchBar.placeholder = "Example: Pizza"
                }
            })
        
        Observable.combineLatest(searchQuery, selectedIndex)
            .flatMapLatest { (query, type) -> Observable<[String]> in
                if query.isEmpty {
                    return Observable.just([])
                }
                switch type {
                case .address:
                    return Observable.just([query])//self.viewModel.searchRegion(query: query).catchErrorJustReturn([])
                case .query:
                    return Observable.just([query])//self.viewModel.searchRegion(query: query).catchErrorJustReturn([])
                }
        }.observeOn(MainScheduler.instance)
            .subscribe(onNext: { (model) in
                print(model)
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
    }
}
