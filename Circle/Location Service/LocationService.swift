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
    fileprivate var locationManager: CLLocationManager
    fileprivate let window = UIApplication.shared.keyWindow
    let userLocation = PublishSubject<CLLocation?>()
    
    fileprivate let geocoder: CLGeocoder = {
        return CLGeocoder()
    }()
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        do {
            let realm = try Realm()
            let favorites = realm.objects(Favorites.self)
            
            favorites.forEach({ (item) in
                let location = CLLocation(latitude: item.location?.latitude ?? 0.0, longitude: item.location?.longitude ?? 0.0)
                startMonitoring(locationRegion: location, radius: 250.0, identifier: "\(item.id)")
            })
        } catch {
            print(error)
        }
    }
    
    func start() {
        stop()
        
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
            
            window?.rootViewController?.present(alertController, animated: true, completion: nil)
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
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(openAction)
            
            window?.rootViewController?.present(alertController, animated: true, completion: nil)
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
    
    fileprivate func regionCreate(with location: CLLocation, radius: Double, identifier: String) -> CLCircularRegion {
        let region = CLCircularRegion(center: location.coordinate, radius: radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    fileprivate func startMonitoring(locationRegion: CLLocation, radius: Double, identifier: String) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            window?.rootViewController?.showAlertLight(title: "Error", message: "Geofencing is not supported on this device!")
            return
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways || CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            window?.rootViewController?.showAlertLight(title: "Warning",
                                                       message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
        }
        let region = regionCreate(with: locationRegion, radius: radius, identifier: identifier)
        locationManager.startMonitoring(for: region)
    }
    
    fileprivate func stopMonitoring(identifier: String) {
        locationManager.monitoredRegions.forEach({ (region) in
            if let circularRegion = region as? CLCircularRegion, circularRegion.identifier == identifier {
                locationManager.stopMonitoring(for: circularRegion)
            }
        })
    }
}

extension LocationService {
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        geocoder.cancelGeocode()
        userLocation.onError(NSError(type: .other, info: error.localizedDescription))
        window?.rootViewController?.showAlertLight(title: "Error", message: "We can't determine your location!\n")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first {
            var distance = 0.0
            var oldLocation = CLLocation()
            
            do {
                let realm = try Realm()
                let location = realm.objects(Location.self).last
                oldLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(location?.latitude ?? 0.0,
                                                                                location?.longitude ?? 0.0),
                                         altitude: location?.altitude ?? 0.0,
                                         horizontalAccuracy: location?.horizontalAccuracy ?? 0.0,
                                         verticalAccuracy: location?.verticalAccuracy ?? 0.0,
                                         course: location?.course ?? 0.0,
                                         speed: location?.speed ?? 0.0,
                                         timestamp: location?.timestamp ?? Date())
                distance = currentLocation.distance(from: oldLocation)
            } catch {
                print(error)
            }
            
            guard (50.0..<100.0).contains(distance) || distance > 100.0 else {
                userLocation.onNext(oldLocation)
                return
            }
            
            userLocation.onNext(currentLocation)
            
            let location = Location()
            location.latitude = currentLocation.coordinate.latitude
            location.longitude = currentLocation.coordinate.longitude
            location.altitude = currentLocation.altitude
            location.horizontalAccuracy = currentLocation.horizontalAccuracy
            location.verticalAccuracy = currentLocation.verticalAccuracy
            location.speed = currentLocation.speed
            location.timestamp = currentLocation.timestamp
            location.course = currentLocation.course
            
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
            start()
        }
    }
}
