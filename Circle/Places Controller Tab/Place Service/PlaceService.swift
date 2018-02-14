//
//  PlaceService.swift
//  Circle
//
//  Created by Kviatkovskii on 31/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift
import Unbox
import FBSDKPlacesKit

struct PlaceService {
    fileprivate let placeManager = FBSDKPlacesManager()
    fileprivate var setting = PlaceSetting()
    
    func loadPlacesForMinDistance() -> Observable<PlaceDataModel> {
        return Observable.create({ (observable) in
            self.placeManager.generateCurrentPlaceRequest(withMinimumConfidenceLevel: .FBSDKPlaceLocationConfidenceLow, fields: self.setting.fields) { (request, error) in
                guard error == nil else {
                    observable.on(.error(error!))
                    return
                }
                _ = request?.start(completionHandler: { (_, result, error) in
                    guard error == nil else {
                        return
                    }
                    
                    if let data = result as? [String: Any], let model: PlaceDataModel = try? unbox(dictionary: data) {
                        observable.on(.next(model))
                    }
                })
            }
            return Disposables.create()
        })
    }
    
    func loadMorePlaces(url: URL) -> Observable<PlaceDataModel> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return URLSession.shared.rx.response(request: request).asObservable()
            .flatMap({ (response, data) -> Observable<PlaceDataModel> in
                guard 200 == response.statusCode else {
                    let error = NSError(type: .other, info: "Recieved a response not 200")
                    return Observable.error(error)
                }
                
                if let model: PlaceDataModel = try? unbox(data: data) {
                    return Observable.just(model)
                } else {
                    let error = NSError(type: .other, info: "Parsing error")
                    return Observable.error(error)
                }
            })
    }
    
    func loadPlaces(_ location: CLLocation?, _ categories: [Categories], _ distance: CLLocationDistance, _ searchTerm: String? = nil) -> Observable<PlaceDataModel> {
        let request = placeManager.placeSearchRequest(for: location,
                                                      searchTerm: searchTerm,
                                                      categories: categories.map({ $0.rawValue }),
                                                      fields: setting.fields,
                                                      distance: distance,
                                                      cursor: nil)
        
        return Observable.create({ observable in
            _ = request?.start(completionHandler: { (_, result, error) in
                guard error == nil else {
                    observable.on(.error(error!))
                    return
                }
                
                if let data = result as? [String: Any], let model: PlaceDataModel = try? unbox(dictionary: data) {
                    observable.on(.next(model))
                }
            })
            return Disposables.create()
        })
    }
}
