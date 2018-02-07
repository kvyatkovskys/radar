//
//  MapViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 13/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import MapKit

final class MapViewController: UIViewController, MKMapViewDelegate {
    typealias Dependecies = HasMapModel
    
    fileprivate let places: [Places]
    fileprivate let location: CLLocation?
    
    fileprivate lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
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
        self.places = dependecies.places
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
        
        if let location = location {
            centerMapOnLocation(location)
            addPointOnMap(places: places)
        }
    }
    
    fileprivate func addPointOnMap(places: [Places]) {
        mapView.removeAnnotations(mapView.annotations)
        
        typealias MapLocations = (location: CLLocationCoordinate2D, title: String?, subTitle: String?)
        var locations: [MapLocations] = []
        places.forEach { (item) in
            item.items.forEach({ place in
                locations.append(MapLocations(location: CLLocationCoordinate2D(latitude: place.location?.latitude ?? 0,
                                                                               longitude: place.location?.longitude ?? 0),
                                              title: place.name,
                                              subTitle: place.location?.street))
            })
        }
        
        locations.forEach { (item) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.location
            annotation.title = item.title
            annotation.subtitle = item.subTitle
            DispatchQueue.main.async { [unowned self] in
                self.mapView.addAnnotation(annotation)
                self.mapView.add(MKCircle(center: item.location, radius: 100.0))
            }
        }
    }
    
    fileprivate func centerMapOnLocation(_ location: CLLocation, radius: Double = FilterDistanceViewModel().defaultDistance) {
        let regionRadius: CLLocationDistance = radius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.black.withAlphaComponent(0.1)
            circleRenderer.fillColor = UIColor.lightGray.withAlphaComponent(0.1)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
