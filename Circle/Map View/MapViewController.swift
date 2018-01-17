//
//  MapViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 13/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import MapKit

final class MapViewController: UIViewController {
    typealias Dependecies = HasMapModel
    
    fileprivate let places: PlacesSections?
    
    fileprivate let location: CLLocation?
    
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
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        mapView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    init(_ dependecies: Dependecies) {
        self.places = dependecies.placesSections
        self.location = dependecies.location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        updateViewConstraints()
        
        if let location = location, let places = places {
            centerMapOnLocation(location)
            addPointOnMap(placesSections: places)
        }
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