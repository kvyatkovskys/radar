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

struct PlaceService {
    fileprivate let placeManager: FBSDKPlacesManager
    fileprivate var setting: PlaceSetting
    
    init() {
        self.placeManager = FBSDKPlacesManager()
        self.setting = PlaceSetting()
    }

    func getInfoAboutPlace(_ location: CLLocation, _ categories: [Categories], _ distance: CLLocationDistance) -> Observable<PlaceDataModel> {
        let request = placeManager.placeSearchRequest(for: location,
                                                      searchTerm: nil,
                                                      categories: categories.map({ $0.rawValue }),
                                                      fields: setting.getFields(),
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
