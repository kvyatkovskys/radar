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
    typealias MapLocations = (location: CLLocationCoordinate2D, title: String?, subTitle: String?)
    
    var places: [PlaceModel] {
        didSet {
            addPointOnMap(places: places)
        }
    }
    var userLocation: CLLocation?
    fileprivate let placeViewModel: PlaceViewModel
    
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
    
    init(places: [PlaceModel], userLocation: CLLocation?, placeViewModel: PlaceViewModel) {
        self.places = places
        self.userLocation = userLocation
        self.placeViewModel = placeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        updateViewConstraints()
        addPointOnMap(places: places)
    }
    
    func addPointOnMap(places: [PlaceModel]) {
        if let location = userLocation {
            centerMapOnLocation(location)
        }
        mapView.removeAnnotations(mapView.annotations)
        
        let locations = places.flatMap({ (place) -> [MapLocations] in
            var locations: [MapLocations] = []
            locations.append(MapLocations(location: CLLocationCoordinate2D(latitude: place.location?.latitude ?? 0,
                                                                           longitude: place.location?.longitude ?? 0),
                                          title: place.name,
                                          subTitle: place.location?.street))
            return locations
        })
        
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
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.hash))
        
        let rightButton = UIButton(type: .detailDisclosure)
        rightButton.tag = annotation.hash
        
        pinView.animatesDrop = true
        pinView.canShowCallout = true
        pinView.rightCalloutAccessoryView = rightButton
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control as? UIButton)?.buttonType == .detailDisclosure {
            dismiss(animated: true, completion: nil)
            if let index = places.index(where: { $0.location?.latitude == view.annotation?.coordinate.latitude
                && $0.location?.longitude == view.annotation?.coordinate.longitude }) {
                self.placeViewModel.openDetailPlace(places[index], FavoritesViewModel())
            }
        }
    }
}
