//
//  MainViewController.swift
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

let heightHeader: CGFloat = 100.0

final class MainViewController: UIViewController, LocationServiceDelegate {    
    typealias Dependecies = HasRouter & HasKingfisher & HasPlaceViewModel
    
    // для работы с геопозиции
    fileprivate lazy var locationService: LocationService = {
        return LocationService(delegate: self)
    }()
    
    fileprivate let router: Router
    fileprivate let viewModel: PlaceViewModel
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    fileprivate let disposeBag = DisposeBag()
    
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
        map.isZoomEnabled = false
        map.isRotateEnabled = true
        map.isScrollEnabled = false
        map.showsBuildings = true
        map.showsCompass = true
        map.showsPointsOfInterest = true
        map.showsUserLocation = true
        map.showsScale = false
        map.contentMode = .scaleAspectFill
        map.isUserInteractionEnabled = false
        return map
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
        self.router = dependencies.router
        self.kingfisherOptions = dependencies.kingfisherOptions
        self.viewModel = dependencies.viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                                            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 28)]
            navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        }
        
        view.backgroundColor = .white
        headerView.addSubview(mapView)
        view.addSubview(tableView)
        tableView.tableHeaderView = headerView
        
        updateConstraints()
        startDetectLocation()
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.cellIndetifier)
        tableView.rx.modelSelected(PlaceModel.self)
            .subscribe(onNext: { (place) in
                print(place)
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] (indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            }).disposed(by: disposeBag)
    }
    
    // MARK: LocationManagerDelegate
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
            
            viewModel.getInfoPlace(location: location)
                .bind(to: tableView.rx.items(cellIdentifier: PlaceTableViewCell.cellIndetifier,
                                             cellType: PlaceTableViewCell.self)) { [unowned self] (_, model: PlaceModel, cell) in
                                                cell.title = model.name
                                                cell.categories = model.categories
                                                cell.imageCell.kf.indicatorType = .activity
                                                cell.imageCell.kf.setImage(with: model.coverPhoto?.url,
                                                                           placeholder: nil,
                                                                           options: self.kingfisherOptions,
                                                                           progressBlock: nil,
                                                                           completionHandler: nil)
                }.disposed(by: disposeBag)
        }
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
}
