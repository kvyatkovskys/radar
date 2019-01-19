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
                                               completionHandler: { (_) in })
            }
            .disposed(by: disposeBag)
        
        resultController.selectResult.asObservable()
            .subscribe(onNext: { [unowned self] (place) in
                self.searchViewModel.openDetailPlace(place, FavoritesViewModel(container: self.container))
                self.searchViewModel.saveQuerySearch(self.searchController.searchBar.text ?? "")
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)
        
        tableView.register(InfoSearchTableViewCell.self, forCellReuseIdentifier: InfoSearchTableViewCell.cellIdentifier)
        tableView.register(SearchQueryTableViewCell.self, forCellReuseIdentifier: SearchQueryTableViewCell.cellIdentifier)
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.cellIndetifier)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        searchViewModel.dataSourceQueries
            .asObservable()
            .bind(to: tableView.rx.items) { (table, row, element) in
                guard row != 0 else {
                    let cell = table.dequeueReusableCell(withIdentifier: InfoSearchTableViewCell.cellIdentifier,
                                                         for: IndexPath(row: row, section: 0)) as? InfoSearchTableViewCell ?? InfoSearchTableViewCell()
                    cell.title = element
                    return cell
                }
                
                let cell = table.dequeueReusableCell(withIdentifier: SearchQueryTableViewCell.cellIdentifier,
                                                     for: IndexPath(row: row, section: 0)) as? SearchQueryTableViewCell ?? SearchQueryTableViewCell()
                cell.title = element
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
                guard indexPath.row != 0 else { return }
                
                let query = self.searchViewModel.dataSourceQueries.value[indexPath.row]
                self.searchController.searchBar.text = query
                self.searchController.isActive = true
                self.searchViewModel.searchQuery.accept(query)
            })
            .disposed(by: disposeBag)
        
        do {
            let realm = try Realm()
            let results = realm.objects(Search.self)
            
            notificationToken = results.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    break
                case .update(let items, _, _, _):
                    var queries: [String] = items.filter("query != ''")
                        .sorted(byKeyPath: "weigth", ascending: false)
                        .distinct(by: ["query"])
                        .map({ $0.query })
                    let endRange = queries.count >= 6 ? 6 : queries.count
                    queries = queries[0..<endRange].map({ $0.localizedCapitalized })
                    queries.insert(NSLocalizedString("tryToFind", comment: "Label when queries empty"), at: 0)
                    self.searchViewModel.dataSourceQueries.accept(queries)
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

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.separatorColor = .lightGray
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
