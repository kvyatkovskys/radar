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
let radius: Double = 800.0

final class PlacesViewController: UIViewController, LocationServiceDelegate, FilterPlacesDelegate {
    typealias Dependecies = HasKingfisher & HasPlaceViewModel
    
    // для работы с геопозиции
    fileprivate lazy var locationService: LocationService = {
        return LocationService(delegate: self)
    }()
    
    fileprivate var notificationToken: NotificationToken?
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
        map.showsScale = false
        map.contentMode = .scaleAspectFill
        return map
    }()
    
    fileprivate lazy var leftBarButton: UIBarButtonItem = {
        let categoriesImage = UIImage(named: "ic_list")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let button = UIBarButtonItem(image: categoriesImage, style: .done, target: self, action: #selector(openCategories))
        button.tintColor = .white
        return button
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
        
        mapView.snp.makeConstraints { (make) in
            make.height.equalTo(heightHeader)
            make.left.bottom.right.equalToSuperview()
        }
        
        super.updateViewConstraints()
    }
    
    init(_ dependencies: Dependecies) {
        self.kingfisherOptions = dependencies.kingfisherOptions
        self.viewModel = dependencies.viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
        view.backgroundColor = .white
        headerView.addSubview(mapView)
        view.addSubview(tableView)
        tableView.tableHeaderView = headerView
        tableView.addSubview(refreshControl)
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.rightBarButtonItem = rightBarButton
        
        updateConstraints()
        startDetectLocation()
        
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.cellIndetifier)
        tableDataSource = PlacesTableViewDataSource(tableView, placesSections: nil, kingfisherOptions: kingfisherOptions)
        tableDelegate = PlacesTableViewDelegate(tableView, placesSections: nil)
        
        refreshControl.rx.controlEvent(.valueChanged).asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                if let location = self.locationService.userLocation {
                    self.loadInfoAboutLocation(location)
                }
            }).disposed(by: disposeBag)
        
        do {
            let realm = try Realm()
            let results = realm.objects(FilterSelectedCategory.self)
            notificationToken = results.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    break
                case .update:
                    if let location = self.locationService.userLocation {
                        self.loadInfoAboutLocation(location)
                    }
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
    
    // MARK: LocationServiceDelegate
    func startDetectLocation() {
        locationService.start { [unowned self] (start) in
            if !start {
                let alertController = UIAlertController(
                    title: "Access to the location is disabled.",
                    message: "To locate the location automatically, open the setting for this application and set i to 'When using the application' or 'Always usage'.",
                    preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let openAction = UIAlertAction(title: "Open settings", style: .default) { _ in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.open(url,
                                                  options: [:],
                                                  completionHandler: { (handler) in
                                                    print(handler)
                        })                    }
                }
                alertController.addAction(openAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func locationService(didFailWithError error: Error) {
        showAlertLight(title: "Error", message: "We can't determine your location!")
    }
    
    func locationService(currentLocation: CLLocation?) {
        if let location = currentLocation {
            centerMapOnLocation(location)
            loadInfoAboutLocation(location)
        }
    }
    
    // MARK: PlaceViewModel
    @objc func openFilter() {
        viewModel.openFilter!(self)
    }
    
    @objc func openCategories() {
        viewModel.openCategories!()
    }
    
    // MARK: FilterPlacesDelegate
    func selectDistance(value: Double) {
        if let location = locationService.userLocation {
            loadInfoAboutLocation(location, distance: value)
        }
    }
    
    // MARK: Current class func
    fileprivate func loadInfoAboutLocation(_ location: CLLocation, distance: Double = FilterDistanceViewModel().defaultDistance) {
        indicatorView.showIndicator()
        viewModel.getInfoPlace(location: location, distance: distance).asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (model) in
                self.tableDataSource?.placesSections = model
                self.tableDelegate?.placesSections = model
                self.tableView.reloadData()
                self.addPointOnMap(placesSections: model)
                
                self.indicatorView.hideIndicator()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                }, onError: { (error) in
                    print(error)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func addPointOnMap(placesSections: PlacesSections) {
        mapView.removeAnnotations(mapView.annotations)
        
        var locations: [CLLocationCoordinate2D] = []
        placesSections.places.forEach({ (place) in
            locations += place.map({ CLLocationCoordinate2D(latitude: $0.location?.latitude ?? 0,
                                                            longitude: $0.location?.longitude ?? 0) })
        })
        
        locations.forEach { (location) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            DispatchQueue.main.async { [unowned self] in
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    fileprivate func centerMapOnLocation(_ location: CLLocation) {
        let regionRadius: CLLocationDistance = radius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
