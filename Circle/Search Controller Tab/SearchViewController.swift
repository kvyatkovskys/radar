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
import RealmSwift

enum SearchDistance: Int {
    case oneThousand, twoThousand, threeThousand, fiveThousand
    
    var title: String {
        switch self {
        case .oneThousand: return "1000 m"
        case .twoThousand: return "2500 m"
        case .threeThousand: return "3500 m"
        case .fiveThousand: return "5000 m"
        }
    }
    
    var value: Double {
        switch self {
        case .oneThousand: return 1000.0
        case .twoThousand: return 2500.0
        case .threeThousand: return 3500.0
        case .fiveThousand: return 5000.0
        }
    }
}

enum ViewType: String {
    case search, savedQueries
}

final class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {

    typealias Dependecies = HasSearchViewModel & HasKingfisher
    
    fileprivate var notificationToken: NotificationToken?
    fileprivate var dataSource: [Places] = []
    fileprivate var dataSourceQueries: [String]
    fileprivate var viewType = ViewType.search
    fileprivate var search: Observable<Places> = Observable.just(Places([], [], [], nil))
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
                                                  SearchDistance.fiveThousand.title]
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
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.dataSource = self
        table.delegate = self
        table.separatorColor = .lightGray
        table.separatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
        
        return table
    }()
    
    fileprivate lazy var titleQuerySearch: UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 50.0))
        label.text = "   You recently searched for"
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17.0)
        return label
    }()
    
    fileprivate lazy var leftBarButton: UIBarButtonItem = {
        let closeImage = UIImage(named: "ic_close")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let button = UIBarButtonItem(image: closeImage, style: .done, target: self, action: #selector(closeSearchQueries))
        button.tintColor = .white
        return button
    }()
    
    fileprivate lazy var indicatorView: ActivityIndicatorView = {
        return ActivityIndicatorView(container: self.view)
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
        self.dataSourceQueries = dependecies.searchViewModel.searchQueries
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.tableHeaderView = titleQuerySearch
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
        
        var isSaveSearchText = false
        let searchDistance = searchController.searchBar.rx.selectedScopeButtonIndex
            .flatMap { Observable.just(SearchDistance(rawValue: $0)) }
        
        let searchQuery = searchController.searchBar.rx.text.orEmpty
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter({ !$0.isEmpty })
        
        Observable.combineLatest(searchDistance, searchQuery)
            .flatMapLatest { [unowned self] (distance, query) -> Observable<Places> in
                return self.searchViewModel.searchQuery(query, distance?.value ?? 0.0).catchErrorJustReturn(Places([], [], [], nil))
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (model) in
                isSaveSearchText = false
                self.resultController.updateTable(places: model)
                }, onError: { (error) in
                    print(error)
            })
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.textDidEndEditing.asObservable()
            .subscribe(onNext: { [unowned self] (_) in
                self.tableView.reloadData()
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
        
        resultController.selectResult.asObservable()
            .subscribe(onNext: { [unowned self] (result) in
                self.searchViewModel.openDetailPlace(result.place, result.title, result.rating, FavoritesViewModel())
                
                if !isSaveSearchText {
                    isSaveSearchText = true
                    self.searchViewModel.saveQuerySearch(self.searchController.searchBar.text ?? "")
                }
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
        
        tableView.register(SearchQueryTableViewCell.self, forCellReuseIdentifier: SearchQueryTableViewCell.cellIdentifier)
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.cellIndetifier)
        
        do {
            let realm = try Realm()
            let results = realm.objects(Search.self)
            
            notificationToken = results.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    if self.dataSourceQueries.isEmpty {
                        self.titleQuerySearch.text = "   Try to find something!"
                    }
                case .update:
                    self.dataSourceQueries = self.searchViewModel.searchQueries
                    if self.viewType == .search {
                        self.tableView.reloadData()
                    }
                    
                    guard !self.dataSourceQueries.isEmpty else {
                        self.titleQuerySearch.text = "   Try to find something!"
                        return
                    }

                    self.titleQuerySearch.text = "   You recently searched for"
                case .error(let error):
                    fatalError("\(error)")
                }
            }
        } catch {
            print(error)
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    @objc func closeSearchQueries() {
        dataSource = []
        navigationItem.leftBarButtonItem = nil
        navigationItem.title = "Find a place"
        viewType = .search
        tableView.tableHeaderView = titleQuerySearch
        tableView.separatorColor = .lightGray
        tableView.reloadData()
        tableView.scrollsToTop = true
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            navigationItem.titleView = searchController.searchBar
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewType {
        case .search: return dataSourceQueries.count
        case .savedQueries: return dataSource.isEmpty ? 0 : dataSource[section].items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewType {
        case .search:
            let querySearch = dataSourceQueries[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchQueryTableViewCell.cellIdentifier,
                                                     for: indexPath) as? SearchQueryTableViewCell ?? SearchQueryTableViewCell()
            
            cell.title = querySearch
            return cell
        case .savedQueries:
            let place = dataSource[indexPath.section].items[indexPath.row]
            let rating = dataSource[indexPath.section].ratings[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.cellIndetifier,
                                                     for: indexPath) as? PlaceTableViewCell ?? PlaceTableViewCell()
            
            cell.rating = rating
            cell.title = place.name
            cell.titleCategory = place.categories?.first?.title
            cell.colorCategory = place.categories?.first?.color
            cell.imageCell.kf.indicatorType = .activity
            cell.imageCell.kf.setImage(with: place.coverPhoto,
                                       placeholder: nil,
                                       options: self.kingfisherOptions,
                                       progressBlock: nil,
                                       completionHandler: nil)
            
            return cell
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewType {
        case .search: return 44.0
        case .savedQueries: return heightTableCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch viewType {
        case .search:
            let query = searchViewModel.searchQueries[indexPath.row]
            navigationItem.leftBarButtonItem = leftBarButton
            viewType = .savedQueries
            tableView.tableHeaderView = nil
            tableView.separatorColor = .clear
            tableView.reloadData()
            indicatorView.showIndicator()
            
            if #available(iOS 11.0, *) {
                navigationItem.searchController = nil
                navigationItem.title = query
            } else {
                navigationItem.titleView = nil
                navigationItem.title = query
            }
            
            searchViewModel.searchQuery(query, SearchDistance.fiveThousand.value).asObservable()
                .subscribe(onNext: { [unowned self] (model) in
                    self.dataSource = [model]
                    tableView.reloadData()
                    self.indicatorView.hideIndicator()
                    }, onError: { [unowned self] (error) in
                        print(error)
                        self.indicatorView.hideIndicator()
                }).disposed(by: disposeBag)
        case .savedQueries:
            let place = dataSource[indexPath.section].items[indexPath.row]
            let title = dataSource[indexPath.section].titles[indexPath.row]
            let rating = dataSource[indexPath.section].ratings[indexPath.row]
            
            searchViewModel.openDetailPlace(place, title, rating, FavoritesViewModel())
        }
    }
}
