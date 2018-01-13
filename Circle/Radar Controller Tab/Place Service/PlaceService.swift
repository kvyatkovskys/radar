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

    init() {
        self.placeManager = FBSDKPlacesManager()
    }

    func getInfoAboutPlace(_ location: CLLocation, _ categories: [Categories], _ distance: CLLocationDistance) -> Observable<[PlaceModel]> {
        let request = placeManager.placeSearchRequest(for: location,
                                                      searchTerm: nil,
                                                      categories: categories.map({ $0.rawValue }),
                                                      fields: [FBSDKPlacesFieldKeyPlaceID,
                                                               FBSDKPlacesFieldKeyName,
                                                               FBSDKPlacesFieldKeyAbout,
                                                               FBSDKPlacesFieldKeyDescription,
                                                               FBSDKPlacesFieldKeyCoverPhoto,
                                                               FBSDKPlacesFieldKeyPhone,
                                                               FBSDKPlacesFieldKeyPaymentOptions,
                                                               FBSDKPlacesFieldKeyHours,
                                                               FBSDKPlacesFieldKeyIsAlwaysOpen,
                                                               FBSDKPlacesFieldKeyIsPermanentlyClosed,
                                                               FBSDKPlacesFieldKeyOverallStarRating,
                                                               FBSDKPlacesFieldKeyRatingCount,
                                                               FBSDKPlacesFieldKeyParking,
                                                               FBSDKPlacesFieldKeyRestaurantServices,
                                                               FBSDKPlacesFieldKeyRestaurantSpecialties,
                                                               FBSDKPlacesFieldKeySingleLineAddress,
                                                               FBSDKPlacesFieldKeyWebsite,
                                                               FBSDKPlacesResponseKeyMatchedCategories,
                                                               FBSDKPlacesFieldKeyLocation],
                                                      distance: distance,
                                                      cursor: nil)
        
        return Observable.create({ observable in
            _ = request?.start(completionHandler: { (_, result, error) in
                guard error == nil else {
                    observable.on(.error(error!))
                    return
                }

                if let data = result as? [String: Any], let model: PlaceDataModel = try? unbox(dictionary: data) {
                    observable.on(.next(model.data))
                }
            })
            return Disposables.create()
        })
    }
}
