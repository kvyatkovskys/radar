//
//  LocationService.swift
//  Circle
//
//  Created by Kviatkovskii on 24/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RealmSwift

final class LocationService: NSObject, CLLocationManagerDelegate {
    fileprivate let locationManager: CLLocationManager
    let userLocation = PublishSubject<CLLocation?>()
    
    fileprivate let geocoder: CLGeocoder = {
        return CLGeocoder()
    }()
    
    fileprivate let controller: UIViewController
    
    init(controller: UIViewController) {
        self.controller = controller
        self.locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
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
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(openAction)
            
            controller.present(alertController, animated: true, completion: nil)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func checkAuthorized() {
        switch CLLocationManager.authorizationStatus() {
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
        default:
            break
        }
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationService {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        geocoder.cancelGeocode()
        userLocation.onError(NSError(type: .other, info: error.localizedDescription))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first {
            userLocation.onNext(currentLocation)
            do {
                let realm = try Realm()
                let oldLocation = realm.objects(Search.self).first
                try realm.write {
                    guard let oldLocation = oldLocation else {
                        let search = Search()
                        search.latitude = currentLocation.coordinate.latitude
                        search.longitude = currentLocation.coordinate.longitude
                        realm.add(search)
                        return
                    }
                    oldLocation.latitude = currentLocation.coordinate.latitude
                    oldLocation.longitude = currentLocation.coordinate.longitude
                }
            } catch {
                print(error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}
