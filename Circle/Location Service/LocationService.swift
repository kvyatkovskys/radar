//
//  LocationService.swift
//  Circle
//
//  Created by Kviatkovskii on 24/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate: class {
    func locationService(didFailWithError error: Error)
    func locationService(currentLocation: CLLocation?)
}

final class LocationService: NSObject, CLLocationManagerDelegate {
    fileprivate weak var delegate: LocationServiceDelegate?
    // для работы с геопозиции
    fileprivate lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        return manager
    }()
    var userLocation: CLLocation?
    
    fileprivate let geocoder: CLGeocoder = {
        return CLGeocoder()
    }()
    
    fileprivate let controller: UIViewController
    
    init(delegate: LocationServiceDelegate, controller: UIViewController) {
        self.delegate = delegate
        self.controller = controller
        super.init()
    }
    
    func start() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.stopUpdatingLocation()
        case .restricted, .denied:
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
            
            controller.present(alertController, animated: true, completion: nil)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationService(didFailWithError: error)
        geocoder.cancelGeocode()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first {
            locationManager.stopUpdatingLocation()
            userLocation = currentLocation
            delegate?.locationService(currentLocation: currentLocation)
        } else {
            delegate?.locationService(currentLocation: nil)
        }
    }
}

extension LocationService {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}
