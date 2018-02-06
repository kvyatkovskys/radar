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

let heightHeader: CGFloat = 100.0

// color for hide map view
fileprivate extension UIColor {
    static var arrowButton: UIColor {
        return UIColor(withHex: 0x34495e, alpha: 1.0)
    }
}

final class PlacesViewController: UIViewController, FilterPlacesDelegate {
    typealias Dependecies = HasKingfisher & HasPlaceViewModel & HasLocationService
    
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
        
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.backgroundColor = .clear
        table.separatorColor = .clear
        return table
    }()
    
    fileprivate lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightHeader))
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var tapViewOnMap: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        let tapOnMap = UITapGestureRecognizer(target: self, action: #selector(showMap))
        view.addGestureRecognizer(tapOnMap)
        
        return view
    }()
    
    fileprivate lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.mapType = .standard
        map.isZoomEnabled = true
        map.isRotateEnabled = true
        map.isScrollEnabled = true
        map.showsBuildings = true
        map.showsCompass = true
        map.showsPointsOfInterest = true
        map.showsUserLocation = true
        map.showsScale = true
        map.contentMode = .scaleAspectFill
        return map
    }()
    
    lazy var rightBarButton: UIBarButtonItem = {
        let categoriesImage = UIImage(named: "ic_filter_list")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let button = UIBarButtonItem(image: categoriesImage, style: .done, target: self, action: #selector(openFilter))
        button.tintColor = .white
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
        
        tapViewOnMap.snp.makeConstraints { (make) in
            make.height.equalTo(heightHeader)
            make.left.top.right.equalToSuperview()
        }
        
        mapView.snp.makeConstraints { (make) in
            make.height.equalTo(heightHeader)
            make.left.top.right.equalToSuperview()
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
        headerView.addSubview(mapView)
        headerView.addSubview(tapViewOnMap)
        view.addSubview(tableView)
        tableView.tableHeaderView = headerView
        tableView.addSubview(refreshControl)
        navigationItem.rightBarButtonItem = rightBarButton
        
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
                self.loadMoreInfoAboutLocation(url: url)
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
        
        do {
            let realm = try Realm()
            let selectedCategories = realm.objects(FilterSelectedCategory.self)
            notificationTokenCategories = selectedCategories.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .update:
                    self.locationService.start()
                case .error(let error):
                    fatalError("\(error)")
                case .initial:
                    break
                }
            }
        } catch {
            print(error)
        }
        
        locationService.userLocation.asObserver()
            .subscribe(onNext: { [unowned self] (location) in
                self.userLocation = location
                self.centerMapOnLocation(location)
                self.loadInfoAboutLocation(location)
            }, onError: { [unowned self] (error) in
                print(error)
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }).disposed(by: disposeBag)
    }
    
    deinit {
        notificationTokenCategories?.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationService.checkAuthorized()
    }
    
    @objc func showMap() {
        viewModel.openMap(tableDataSource?.places ?? [], userLocation, tapViewOnMap.frame)
    }
    
    // MARK: PlaceViewModel
    @objc func openFilter() {
        viewModel.openFilter(self)
    }
    
    // MARK: FilterPlacesDelegate
    func selectDistance(value: Double) {
        if let location = userLocation {
            loadInfoAboutLocation(location, distance: value)
            centerMapOnLocation(location, radius: value)
        }
    }
    
    // MARK: Current class func
    fileprivate func loadMoreInfoAboutLocation(url: URL) {
        viewModel.loadMoreInfoPlaces(url: url).asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (model) in
                self.tableDataSource?.places += [model]
                self.tableDelegate?.places += [model]
                self.tableView.reloadData()
                self.addPointOnMap(places: model, removeOldAnnotations: false)
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func loadInfoAboutLocation(_ location: CLLocation?, distance: Double = FilterDistanceViewModel().defaultDistance) {
        indicatorView.showIndicator()
        viewModel.getInfoPlaces(location: location, distance: distance).asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (model) in
                self.tableDataSource?.places = [model]
                self.tableDelegate?.places = [model]
                self.tableView.reloadData()
                self.addPointOnMap(places: model)
                
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
    
    fileprivate func addPointOnMap(places: Places, removeOldAnnotations: Bool = true) {
        if removeOldAnnotations {
            mapView.removeAnnotations(mapView.annotations)
        }
        let locations = places.items.map({ CLLocationCoordinate2D(latitude: $0.location?.latitude ?? 0,
                                                                  longitude: $0.location?.longitude ?? 0) })
        
        locations.forEach { (location) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            DispatchQueue.main.async { [unowned self] in
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    fileprivate func centerMapOnLocation(_ location: CLLocation?, radius: Double = FilterDistanceViewModel().defaultDistance) {
        if let location = location {
            let regionRadius: CLLocationDistance = radius
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
            mapView.setRegion(coordinateRegion, animated: false)
        }
    }
}
