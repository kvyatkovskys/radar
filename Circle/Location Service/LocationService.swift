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
import UserNotifications

final class LocationService: NSObject, CLLocationManagerDelegate {
    typealias LocationMonitoring = (location: CLLocation?, monitoring: Bool)
    
    fileprivate var locationManager: CLLocationManager
    fileprivate let window = UIApplication.shared.keyWindow
    fileprivate var notificationTokenSettings: NotificationToken?
    fileprivate var notificationTokenFavorites: NotificationToken?
    let userLocation = PublishSubject<LocationMonitoring>()
    
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
            let settings = realm.objects(Settings.self)
            let favorites = realm.objects(Favorites.self)
            
            notificationTokenFavorites = favorites.observe({ [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    break
                case .update(let favorite, _, _, _):
                    let settingsIsDisabled = realm.objects(Settings.self).first
                    guard let disabledNotice = settingsIsDisabled?.disabledNotice, disabledNotice == false else {
                        print("notifications are disabled")
                        return
                    }
                   
                    self.stopMonitoring()
                    favorite.filter({ $0.notify == true }).forEach({ (item) in
                        let location = CLLocation(latitude: item.latitude, longitude: item.longitude)
                        self.startMonitoring(locationRegion: location, radius: 100.0, identifier: "\(item.id)")
                    })
                case .error(let error):
                    fatalError("\(error)")
                }
            })
            
            notificationTokenSettings = settings.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .update(let setting, _, _, _), .initial(let setting):
                    let favoritesIsNotify = realm.objects(Favorites.self).filter("notify = 1")
                    
                    guard let disabledNotice = setting.first?.disabledNotice, disabledNotice == false else {
                        self.stopMonitoring()
                        return
                    }
                    
                    favoritesIsNotify.forEach({ (item) in
                        self.stopMonitoring()
                        let location = CLLocation(latitude: item.latitude, longitude: item.longitude)
                        self.startMonitoring(locationRegion: location, radius: 100.0, identifier: "\(item.id)")
                    })
                case .error(let error):
                    fatalError("\(error)")
                }
            }
        } catch {
            print(error)
        }
    }
    
    deinit {
        notificationTokenSettings?.invalidate()
        notificationTokenFavorites?.invalidate()
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
                title: NSLocalizedString("locationDisabled", comment: "Title for alert that location is disabled"),
                message: NSLocalizedString("textAccessToLocation", comment: "Text for alert that location is disabled"),
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Title for button cancel"),
                                             style: .cancel,
                                             handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: NSLocalizedString("openSettings", comment: "Title for button that to open settings"),
                                           style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
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
            let alertController = UIAlertController(title: NSLocalizedString("locationDisabled",
                                                                             comment: "Title for alert that location is disabled"),
                                                    message: NSLocalizedString("textAccessToLocation",
                                                                               comment: "Text for alert that location is disabled"),
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Title for button cancel"),
                                             style: .cancel,
                                             handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: NSLocalizedString("openSettings", comment: "Title for button that to open settings"),
                                           style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
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
            window?.rootViewController?.showAlertLight(title: NSLocalizedString("error", comment: "Title for error"),
                                                       message: NSLocalizedString("geofencingNotSupport",
                                                                                  comment: "Text for alert when geofencinh not supporting"))
            return
        }
        
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else { return }
        
        let region = regionCreate(with: locationRegion, radius: radius, identifier: identifier)
        locationManager.startMonitoring(for: region)
    }
    
    fileprivate func stopMonitoring() {
        locationManager.monitoredRegions.forEach({ (region) in
            if let circularRegion = region as? CLCircularRegion {
                locationManager.stopMonitoring(for: circularRegion)
            }
        })
    }
}

extension LocationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        completionHandler()
    }
}

extension LocationService {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            do {
                let realm = try Realm()
                let favorites = realm.objects(Favorites.self).filter("id = \(region.identifier)")
                if let favorite = favorites.first {
                    let notification = KSNotifications(center: UNUserNotificationCenter.current())
                    notification.center.delegate = self
                    notification.showNotification(favorite: favorite)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        geocoder.cancelGeocode()
        userLocation.onError(error)
        window?.rootViewController?.showAlertLight(title: NSLocalizedString("error",
                                                                            comment: "Error when the manager didn't detect the current position"),
                                                   message: NSLocalizedString("notDetermineLocation",
                                                                              comment: "Text for alert when the manager didn't detect the current position"))
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

            guard distance > 500.0 else {
                userLocation.onNext(LocationMonitoring(oldLocation, false))
                return
            }
            
            userLocation.onNext(LocationMonitoring(currentLocation, true))
            
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
            
            do {
                let realm = try Realm()
                let settings = realm.objects(Settings.self).first
                try realm.write {
                    guard let oldSettings = settings else {
                        let newSettings = Settings()
                        newSettings.allwaysLocation = status == .authorizedAlways
                        newSettings.disabledNotice = settings?.disabledNotice ?? false
                        newSettings.typeViewMainTab = settings?.typeViewMainTab ?? 0
                        realm.add(newSettings)
                        return
                    }
                    oldSettings.allwaysLocation = status == .authorizedAlways
                }
            } catch {
                print(error)
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
