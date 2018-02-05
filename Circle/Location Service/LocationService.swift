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
    
    fileprivate func getAddressFromLocation(_ coordinates: CLLocation, completion: @escaping(_ street: String?, _ city: String?, _ country: String?, _ region: String?, _ error: Error?) -> Void) {
        geocoder.reverseGeocodeLocation(coordinates) { (placemarks, error) in
            if error == nil, let place = placemarks?.first {
                let street = place.addressDictionary?["Thoroughfare"] as? String
                let city = place.addressDictionary?["City"] as? String
                let country = place.addressDictionary?["Country"] as? String
                let region = place.addressDictionary?["State"] as? String
                completion(street, city, country, region, nil)
            } else {
                completion(nil, nil, nil, nil, error)
            }
        }
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

            let location = Location()
            location.latitude = currentLocation.coordinate.latitude
            location.longitude = currentLocation.coordinate.longitude
            location.altitude = currentLocation.altitude
            location.horizontalAccuracy = currentLocation.horizontalAccuracy
            location.verticalAccuracy = currentLocation.verticalAccuracy
            location.speed = currentLocation.speed
            location.timestamp = currentLocation.timestamp
            
            getAddressFromLocation(currentLocation, completion: { (street, city, country, region, error) in
                if error == nil {
                    location.street = street
                    location.city = city
                    location.country = country
                    location.region = region
                }
                
                do {
                    let realm = try Realm()
                    let oldLocation = realm.objects(Location.self).last
                    
                    guard location.latitude != oldLocation?.latitude && location.longitude != oldLocation?.longitude else { return }
                    
                    try realm.write {
                        realm.add(location)
                    }
                } catch {
                    print(error)
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}
