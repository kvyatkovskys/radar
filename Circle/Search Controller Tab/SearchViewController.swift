//
//  SearchViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 27/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift

final class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {

    typealias Dependecies = HasSearchViewModel
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let resultController = ResultSearchViewController()
    fileprivate let searchViewModel: SearchViewModel
    
    fileprivate lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: resultController)
        controller.delegate = self
        controller.searchBar.placeholder = "Enter: Pizza"
        controller.searchBar.delegate = self
        controller.searchBar.searchBarStyle = .default
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
    
    init(_ dependecies: Dependecies) {
        self.searchViewModel = dependecies.searchViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        searchController.searchBar.rx.text.orEmpty
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter({ !$0.isEmpty })
            .flatMapLatest { (query) -> Observable<Places> in
                if query.isEmpty {
                    return Observable.just(Places([], [], [], nil))
                }
                return self.searchViewModel.searchQuery(query).catchErrorJustReturn(Places([], [], [], nil))
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (model) in
                print(model)
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
    }
}
