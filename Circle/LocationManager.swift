//
//  LocationManager.swift
//  Circle
//
//  Created by Kviatkovskii on 24/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func locationManager(didFailWithError error: Error)
    func locationManager(currentLocation: CLLocation?)
}

final class LocationManager: NSObject, CLLocationManagerDelegate {
    fileprivate weak var delegate: LocationManagerDelegate?
    // для работы с геопозиции
    fileprivate lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    fileprivate let geocoder: CLGeocoder = {
        return CLGeocoder()
    }()
    
    init(delegate: LocationManagerDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func start(monitoring: @escaping (_ start: Bool) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            DispatchQueue.main.async(execute: { [unowned self] in
                // определяем местоположение юзера
                if CLLocationManager.locationServicesEnabled() {
                    self.locationManager.startUpdatingLocation()
                    monitoring(true)
                }
            })
        case .notDetermined:
            locationManager.stopUpdatingLocation()
        case .restricted, .denied:
            locationManager.stopUpdatingLocation()
            monitoring(false)
        default:
            break
        }
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationManager(didFailWithError: error)
        geocoder.cancelGeocode()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first {
            locationManager.stopUpdatingLocation()
            delegate?.locationManager(currentLocation: currentLocation)
        } else {
            delegate?.locationManager(currentLocation: nil)
        }
    }
}
