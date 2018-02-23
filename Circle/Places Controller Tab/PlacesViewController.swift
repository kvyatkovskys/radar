//
//  PlacesViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 08/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import SnapKit
import MapKit
import RxSwift
import RxCocoa
import Kingfisher
import RealmSwift

final class PlacesViewController: UIViewController {
    typealias Dependecies = HasKingfisher & HasPlaceViewModel & HasLocationService
    
    fileprivate let heightHeader: CGFloat = 100.0
    fileprivate var searchForMinDistance: Bool = false
    fileprivate var locationService: LocationService
    fileprivate var userLocation: CLLocation?
    fileprivate var notificationTokenCategories: NotificationToken?
    fileprivate var notificationTokenDistance: NotificationToken?
    fileprivate var viewModel: PlaceViewModel
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    fileprivate let disposeBag = DisposeBag()
    fileprivate var tableDataSource: PlacesTableViewDataSource?
    //swiftlint:disable weak_delegate
    fileprivate var tableDelegate: PlacesTableViewDelegate?
        
    fileprivate lazy var tableView: KSTableView = {
        let table = KSTableView()
        return table
    }()
    
    lazy var rightBarButton: UIBarButtonItem = {
        let categoriesImage = UIImage(named: "ic_filter_list")?.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: categoriesImage, style: .done, target: self, action: #selector(openFilter))
        return button
    }()
    
    lazy var leftBarButton: UIBarButtonItem = {
        let categoriesImage = UIImage(named: "ic_map")?.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: categoriesImage, style: .done, target: self, action: #selector(showMap))
        return button
    }()
    
    fileprivate lazy var indicatorView: ActivityIndicatorView = {
        return ActivityIndicatorView(container: self.view)
    }()
    
    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    fileprivate func updateConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(64.0)
            make.bottom.left.right.equalToSuperview()
        }
        
        super.updateViewConstraints()
    }
    
    init(_ dependencies: Dependecies) {
        self.kingfisherOptions = dependencies.kingfisherOptions
        self.viewModel = dependencies.viewModel
        self.locationService = dependencies.locationService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.addSubview(refreshControl)
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.leftBarButtonItem = leftBarButton
        
        updateConstraints()
        locationService.start()
        
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.cellIndetifier)
        tableDataSource = PlacesTableViewDataSource(tableView, kingfisherOptions: kingfisherOptions)
        tableDelegate = PlacesTableViewDelegate(tableView, viewModel: viewModel)
        
        refreshControl.rx.controlEvent(.valueChanged).asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.locationService.start()
            }).disposed(by: disposeBag)
        
        tableDelegate?.nextUrl.asObserver()
            .subscribe(onNext: { [unowned self] (url) in
                self.loadMorePlacesLocation(url: url)
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
        
        do {
            let realm = try Realm()
            let selectedCategories = realm.objects(FilterSelectedCategory.self)
            let filterDistance = realm.objects(FilterSelectedDistance.self)
            
            notificationTokenCategories = selectedCategories.observe({ [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .update:
                    self.locationService.start()
                case .error(let error):
                    fatalError("\(error)")
                case .initial:
                    break
                }
            })
            
            notificationTokenDistance = filterDistance.observe({ [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial(let filter):
                    self.searchForMinDistance = filter.first?.searchForMinDistance ?? false
                    guard self.searchForMinDistance else { return }
                    self.loadPlacesForMinDistance()
                case .update(let filter, _, _, _):
                    let searchFilter = filter.first
                    self.searchForMinDistance = searchFilter?.searchForMinDistance ?? false
                    guard self.searchForMinDistance == false else {
                        self.loadPlacesForMinDistance()
                        return
                    }
                    self.searchForNewDistance(value: searchFilter?.distance ?? 1000.0)
                case .error(let error):
                    fatalError("\(error)")
                }
            })
        } catch {
            print(error)
        }
        
        locationService.userLocation.asObserver()
            .subscribe(onNext: { [unowned self] (location) in
                self.indicatorView.showIndicator()
                self.userLocation = location
                guard self.searchForMinDistance == false else { return }
                self.loadPlacesLocation(location)
            }, onError: { [unowned self] (error) in
                print(error)
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }).disposed(by: disposeBag)
    }
    
    deinit {
        notificationTokenCategories?.invalidate()
        notificationTokenDistance?.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationService.checkAuthorized()
    }
    
    @objc func showMap() {
        viewModel.openMap(tableDataSource?.places ?? [], userLocation)
    }
    
    fileprivate func searchForNewDistance(value: Double) {
        if let location = userLocation {
            indicatorView.showIndicator()
            loadPlacesLocation(location, distance: value)
        }
    }
    
    // MARK: PlaceViewModel
    @objc func openFilter() {
        viewModel.openFilter()
    }
    
    // MARK: Current class func
    fileprivate func loadPlacesForMinDistance() {
        indicatorView.showIndicator()
        viewModel.getPlacesFirMinDistance().asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (model) in
                self.tableDataSource?.places = [model]
                self.tableDelegate?.places = [model]
                self.tableView.reloadData()
                
                self.indicatorView.hideIndicator()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }, onError: { (error) in
                print(error)
                self.indicatorView.hideIndicator()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }).disposed(by: disposeBag)
    }
    
    fileprivate func loadMorePlacesLocation(url: URL) {
        viewModel.getMorePlaces(url: url).asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (model) in
                self.tableDataSource?.places += [model]
                self.tableDelegate?.places += [model]
                self.tableView.reloadData()
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func loadPlacesLocation(_ location: CLLocation?, distance: Double = FilterDistanceViewModel().defaultDistance) {
        viewModel.getPlaces(location: location, distance: distance).asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (model) in
                self.tableDataSource?.places = [model]
                self.tableDelegate?.places = [model]
                self.tableView.reloadData()

                self.indicatorView.hideIndicator()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                }, onError: { [unowned self] (error) in
                    print(error)
                    self.indicatorView.hideIndicator()
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
            }).disposed(by: disposeBag)
    }
}
