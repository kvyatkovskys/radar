//
//  SearchViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 27/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

enum SearchDistance: Int {
    case oneThousand, twoThousand, threeThousand, fourThousand
    
    var title: String {
        switch self {
        case .oneThousand: return "1000 m"
        case .twoThousand: return "2000 m"
        case .threeThousand: return "3000 m"
        case .fourThousand: return "4000 m"
        }
    }
    
    var value: Double {
        switch self {
        case .oneThousand: return 1000.0
        case .twoThousand: return 2000.0
        case .threeThousand: return 3000.0
        case .fourThousand: return 4000.0
        }
    }
}

final class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {

    typealias Dependecies = HasSearchViewModel & HasKingfisher
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let searchViewModel: SearchViewModel
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    fileprivate lazy var resultController: ResultSearchViewController = {
        return ResultSearchViewController(ResultSearchDependecies(self.kingfisherOptions))
    }()
    
    fileprivate lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: resultController)
        controller.delegate = self
        controller.searchBar.placeholder = "Enter: Pizza"
        controller.searchBar.delegate = self
        controller.searchBar.searchBarStyle = .default
        controller.searchBar.scopeButtonTitles = [SearchDistance.oneThousand.title,
                                                  SearchDistance.twoThousand.title,
                                                  SearchDistance.threeThousand.title,
                                                  SearchDistance.fourThousand.title]
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
        table.tableFooterView = UIView(frame: CGRect.zero)
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
        self.kingfisherOptions = dependecies.kingfisherOptions
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
        
        let searchDistance = searchController.searchBar.rx.selectedScopeButtonIndex.asObservable()
            .flatMap { Observable.just(SearchDistance(rawValue: $0)) }
        
        let searhQuery = searchController.searchBar.rx.text.orEmpty
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter({ !$0.isEmpty })
            
            Observable.combineLatest(searchDistance, searhQuery)
            .flatMapLatest { [unowned self] (distance, query) -> Observable<Places> in
                if query.isEmpty {
                    return Observable.just(Places([], [], [], nil))
                }
                return self.searchViewModel.searchQuery(query, distance?.value ?? 0.0).catchErrorJustReturn(Places([], [], [], nil))
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (model) in
                self.resultController.updateTable(places: model)
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
        
        resultController.selectResult.asObservable()
            .subscribe(onNext: { [unowned self] (result) in
                self.searchViewModel.openDetailPlace(result.place, result.title, result.rating, FavoritesViewModel())
                self.searchViewModel.saveQuerySearch(self.searchController.searchBar.text ?? "")
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
    }
}
