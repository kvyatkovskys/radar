//
//  DetailAddressTableViewCell.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import MapKit
import Contacts
import MapKit

final class DetailAddressTableViewCell: UITableViewCell, MKMapViewDelegate {
    static var cellIdentifier = "DetailAddressTableViewCell"
    
    fileprivate let addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15.0)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    fileprivate lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
        map.mapType = .standard
        map.showsBuildings = true
        map.showsCompass = true
        map.contentMode = .scaleAspectFill
        return map
    }()
    
    fileprivate lazy var mapButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openMap))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    override func updateConstraints() {
        super.updateConstraints()
        
        addressLabel.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(10.0)
            make.bottom.equalTo(mapView.snp.top).offset(-10.0)
        }
        
        mapView.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10.0)
        }
        
        mapButtonView.snp.remakeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    var address: String? {
        didSet {
            addressLabel.text = address
        }
    }
    
    var title: String?
    
    var location: LocationPlace? {
        didSet {
            if let location = location {
                addPointOnMap(location)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(addressLabel)
        addSubview(mapView)
        addSubview(mapButtonView)
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openMap() {
        let latitude: CLLocationDegrees = location?.latitude ?? 0
        let longitude: CLLocationDegrees = location?.longitude ?? 0
        
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                       MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]

        let state = location?.state ?? ""
        let zip = location?.zip ?? ""
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: [CNPostalAddressStreetKey: location?.street as Any,
                                                                                 CNPostalAddressCityKey: location?.city as Any,
                                                                                 CNPostalAddressCountryKey: location?.country as Any,
                                                                                 CNPostalAddressStateKey: state as Any,
                                                                                 CNPostalAddressPostalCodeKey: zip as Any])
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        mapItem.openInMaps(launchOptions: options)
    }
    
    func addPointOnMap(_ place: LocationPlace) {
        centerMapOnLocation(place.coordinate)
        mapView.removeAnnotations(mapView.annotations)
        
        let coordinate2D = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate2D
        annotation.title = title
        
        DispatchQueue.main.async { [unowned self] in
            self.mapView.addAnnotation(annotation)
            self.mapView.addOverlay(MKCircle(center: coordinate2D, radius: 100.0))
        }
    }
    
    fileprivate func centerMapOnLocation(_ location: CLLocation) {
        let regionRadius: CLLocationDistance = 200
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
