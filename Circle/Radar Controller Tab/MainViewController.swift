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

let heightHeader: CGFloat = 100.0

final class MainViewController: UIViewController, LocationManagerDelegate, UIScrollViewDelegate, UITableViewDelegate {
    typealias Dependecies = HasRouter
    
    // для работы с геопозиции
    fileprivate lazy var locationsManager: LocationManager = {
        return LocationManager(delegate: self)
    }()
    
    fileprivate let router: Router
    fileprivate let placeManager = PlaceManager()
    fileprivate var tableHeaderHeight: Constraint?
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        //table.tableFooterView = UIView(frame: CGRect.zero)
        table.delegate = self
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
            tableHeaderHeight = make.height.equalTo(heightHeader).constraint
            make.left.bottom.right.equalToSuperview()
        }
        
        super.updateViewConstraints()
    }
    
    init(_ dependencies: Dependecies) {
        self.router = dependencies.router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.addSubview(mapView)
        view.addSubview(tableView)
        tableView.tableHeaderView = headerView
        
        updateConstraints()
        startDetectLocation()
    }
    
    // MARK: UIScrollDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let header = tableView.tableHeaderView else { return }
        
        let offsetY = -scrollView.contentOffset.y
        tableHeaderHeight?.update(offset: max(header.bounds.height, header.bounds.height + offsetY))        
        view.layoutIfNeeded()
    }
    
    // MARK: LocationManagerDelegate
    func startDetectLocation() {
        locationsManager.start { [unowned self] (start) in
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
    
    func locationManager(didFailWithError error: Error) {
        showAlertLight(title: "Error", message: "We can't determine your location!")
    }
    
    func locationManager(currentLocation: CLLocation?) {
        if let location = currentLocation {
            centerMapOnLocation(location)
            placeManager.getInfoAboutPlace(location: location)
        }
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
