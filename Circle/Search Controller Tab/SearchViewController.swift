//
//  SearchViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 27/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import Swinject

final class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    fileprivate var notificationToken: NotificationToken?
    fileprivate let disposeBag = DisposeBag()
    fileprivate var searchViewModel: SearchViewModel
    fileprivate let container: Container
    fileprivate lazy var resultController: ResultSearchViewController = {
        return ResultSearchViewController(container)
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
        self.container = container
        self.searchViewModel = container.resolve(SearchViewModel.self)!
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
        
        searchController.searchBar.rx.text.orEmpty
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter({ !$0.isEmpty })
            .bind(to: searchViewModel.searchQuery)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(searchDistance, searchViewModel.searchQuery)
            .filter({ $1 != "" })
            .flatMapLatest { [unowned self] (distance, query) -> Observable<[PlaceModel]> in
                self.searchViewModel.searchQuery(query, distance?.value ?? 0.0)
                return Observable.just(self.searchViewModel.placeViewModel.places.value.data)
            }
            .bind(to: resultController.tableView.rx
                .items(cellIdentifier: PlaceTableViewCell.cellIndetifier, cellType: PlaceTableViewCell.self)) { (_, result, cell) in
                    cell.rating = result.rating
                    cell.title = result.name
                    cell.titleCategory = result.categories?.first?.title
                    cell.colorCategory = result.categories?.first?.color
                    cell.imageCell.kf.indicatorType = .activity
                    cell.imageCell.kf.setImage(with: result.coverPhoto,
                                               placeholder: nil,
                                               options: self.searchViewModel.kingfisherOptions,
                                               progressBlock: nil,
                                               completionHandler: nil)
            }
            .disposed(by: disposeBag)
        
        resultController.selectResult.asObservable()
            .subscribe(onNext: { [unowned self] (place) in
                self.searchViewModel.openDetailPlace(place, FavoritesViewModel(container: self.container))
                if !isSaveSearchText {
                    isSaveSearchText = true
                    self.searchViewModel.saveQuerySearch(self.searchController.searchBar.text ?? "")
                }
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)
        
        tableView.register(InfoSearchTableViewCell.self, forCellReuseIdentifier: InfoSearchTableViewCell.cellIdentifier)
        tableView.register(SearchQueryTableViewCell.self, forCellReuseIdentifier: SearchQueryTableViewCell.cellIdentifier)
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.cellIndetifier)
        
        do {
            let realm = try Realm()
            let results = realm.objects(Search.self)
            
            notificationToken = results.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .update, .initial:
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
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.dataSourceQueries.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let querySearch = searchViewModel.dataSourceQueries.value[indexPath.row]
        
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
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.separatorColor = .lightGray
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row != 0 else { return }
        
        let query = searchViewModel.dataSourceQueries.value[indexPath.row]
        searchController.searchBar.text = query
        searchController.isActive = true
        searchViewModel.searchQuery.accept(query)
    }
}
