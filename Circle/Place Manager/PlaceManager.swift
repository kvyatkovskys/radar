//
//  PlaceManager.swift
//  Circle
//
//  Created by Kviatkovskii on 31/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift
import Unbox

enum Categories: String {
    case arts = "ARTS_ENTERTAINMENT"
    case education = "EDUCATION"
    case fitness = "FITNESS_RECREATION"
    case food = "FOOD_BEVERAGE"
    case hotel = "HOTEL_LODGING"
    case medical = "MEDICAL_HEALTH"
    case shopping = "SHOPPING_RETAIL"
    case travel = "TRAVEL_TRANSPORTATION"
}

struct PlaceManager {
    fileprivate let placeManager: FBSDKPlacesManager

    init() {
        self.placeManager = FBSDKPlacesManager()
    }
    //results: @escaping ([PlaceModel]) -> Void)
    func getInfoAboutPlace(location: CLLocation,
                           categories: [Categories] = [.arts, .education, .fitness, .food, .hotel, .medical, .shopping, .travel],
                           distance: CLLocationDistance = 1000) -> Observable<[PlaceModel]> {
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
            request?.start(completionHandler: { (_, result, error) in
                guard error == nil else {
                    observable.on(.error(error!))
                    return
                }
                
                if let data = result as? [String: Any], let model: PlaceDataModel = try? unbox(dictionary: data) {
                    observable.on(.next(model.data))
                    observable.on(.completed)
                }
            })
            return Disposables.create()
        })
    }
}
