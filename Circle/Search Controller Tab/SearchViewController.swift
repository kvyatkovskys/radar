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
import Swinject

final class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    fileprivate var notificationToken: NotificationToken?
    fileprivate var dataSource: [PlaceModel] = []
    fileprivate var dataSourceQueries: [String] = [NSLocalizedString("tryToFind", comment: "Label when queries empty")]
    fileprivate var viewType = ViewType.search
    fileprivate var search: Observable<PlaceModel?> = Observable.just(nil)
    fileprivate let disposeBag = DisposeBag()
    fileprivate let searchViewModel: SearchViewModel
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    fileprivate lazy var resultController: ResultSearchViewController = {
        return ResultSearchViewController(ResultSearchDependecies(self.kingfisherOptions))
    }()
    
    fileprivate lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: resultController)
        controller.delegate = self
        controller.searchBar.placeholder = NSLocalizedString("title", comment: "Title for label")
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
            controller.searchBar.tintColor = .white
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .black
        } else {
            controller.searchBar.tintColor = .navBarColor
        }
        self.definesPresentationContext = true
        return controller
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.dataSource = self
        table.delegate = self
        return table
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
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    init(_ container: Container) {
        self.searchViewModel = container.resolve(SearchViewModel.self)!
        self.kingfisherOptions = container.resolve(KingfisherOptionsInfo.self)!
        self.dataSourceQueries += self.searchViewModel.searchQueries
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
            tableView.tableHeaderView = searchController.searchBar
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
            .flatMapLatest { [unowned self] (distance, query) -> Observable<[PlaceModel]> in
                return self.searchViewModel.searchQuery(query, distance?.value ?? 0.0).catchErrorJustReturn([])
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
        
        tableView.register(InfoSearchTableViewCell.self, forCellReuseIdentifier: InfoSearchTableViewCell.cellIdentifier)
        tableView.register(SearchQueryTableViewCell.self, forCellReuseIdentifier: SearchQueryTableViewCell.cellIdentifier)
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.cellIndetifier)
        
        do {
            let realm = try Realm()
            let results = realm.objects(Search.self)
            
            notificationToken = results.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    if self.searchViewModel.searchQueries.isEmpty {
                        self.dataSourceQueries.replaceSubrange(0..., with: [NSLocalizedString("tryToFind",
                                                                                              comment: "Label when queries empty")])
                    } else {
                        let localized = NSLocalizedString("recentlySearched", comment: "Label when queries not empty")
                        self.dataSourceQueries.replaceSubrange(0...,
                                                               with: [localized] + self.searchViewModel.searchQueries)
                    }
                    self.tableView.reloadData()
                case .update:
                    if self.searchViewModel.searchQueries.isEmpty {
                        self.dataSourceQueries.replaceSubrange(0..., with: [NSLocalizedString("tryToFind",
                                                                                              comment: "Label when queries empty")])
                    } else {
                        let localized = NSLocalizedString("recentlySearched", comment: "Label when queries not empty")
                        self.dataSourceQueries.replaceSubrange(0...,
                                                               with: [localized] + self.searchViewModel.searchQueries)
                    }
                    self.tableView.reloadData()
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
        navigationItem.title = NSLocalizedString("findPlace", comment: "Title for navigation bar in search tab")
        viewType = .search
        tableView.separatorColor = .lightGray
        tableView.reloadData()
        tableView.scrollsToTop = true
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewType {
        case .search: return dataSourceQueries.count
        case .savedQueries: return dataSource.isEmpty ? 0 : 0//dataSource[section].items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewType {
        case .search:
            let querySearch = dataSourceQueries[indexPath.row]
            
            guard indexPath.row != 0 else {
                let cell = tableView.dequeueReusableCell(withIdentifier: InfoSearchTableViewCell.cellIdentifier,
                                                         for: indexPath) as? InfoSearchTableViewCell ?? InfoSearchTableViewCell()
                
                cell.title = querySearch
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchQueryTableViewCell.cellIdentifier,
                                                     for: indexPath) as? SearchQueryTableViewCell ?? SearchQueryTableViewCell()
            
            cell.title = querySearch
            return cell
        case .savedQueries:
//            let place = dataSource[indexPath.section].items[indexPath.row]
//            let rating = dataSource[indexPath.section].ratings[indexPath.row]
//            let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.cellIndetifier,
//                                                     for: indexPath) as? PlaceTableViewCell ?? PlaceTableViewCell()
//
//            cell.rating = rating
//            cell.title = place.name
//            cell.titleCategory = place.categories?.first?.title
//            cell.colorCategory = place.categories?.first?.color
//            cell.imageCell.kf.indicatorType = .activity
//            cell.imageCell.kf.setImage(with: place.coverPhoto,
//                                       placeholder: nil,
//                                       options: self.kingfisherOptions,
//                                       progressBlock: nil,
//                                       completionHandler: nil)
            
            //return cell
            return UITableViewCell()
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.separatorColor = .lightGray
        guard viewType == .savedQueries else {
            tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
            return
        }
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewType {
        case .search: return 44.0
        case .savedQueries: return heightTableCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row != 0 else { return }
        
        switch viewType {
        case .search:
            let query = dataSourceQueries[indexPath.row]
            navigationItem.leftBarButtonItem = leftBarButton
            viewType = .savedQueries
            tableView.reloadData()
            indicatorView.showIndicator()
            
            if #available(iOS 11.0, *) {
                navigationItem.searchController = nil
                navigationItem.title = query
            } else {
                tableView.tableHeaderView = nil
                navigationItem.title = query
            }
            
            searchViewModel.searchQuery(query, SearchDistance.fiveThousand.value).asObservable()
                .subscribe(onNext: { [unowned self] (model) in
                    self.dataSource = model
                    tableView.reloadData()
                    self.indicatorView.hideIndicator()
                    }, onError: { [unowned self] (error) in
                        print(error)
                        self.indicatorView.hideIndicator()
                }).disposed(by: disposeBag)
        case .savedQueries:
            break
//            let place = dataSource[indexPath.section].items[indexPath.row]
//            let title = dataSource[indexPath.section].titles[indexPath.row]
//            let rating = dataSource[indexPath.section].ratings[indexPath.row]
//
//            searchViewModel.openDetailPlace(place, title, rating, FavoritesViewModel())
        }
    }
}
