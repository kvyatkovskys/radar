//
//  PlaceManager.swift
//  Circle
//
//  Created by Kviatkovskii on 31/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation

enum Categories: String {
    case arts = "ARTS_ENTERTAINMENT"
    case education = "EDUCATION"
    case fitness = "FITNESS_RECREATION"
    case food = "FOOD_BEVERAGE"
    case hotel = "HOTEL_LODGING"
    case medical = "MEDICAL_HEALTH"
    case shopping = "SHOPPING_RETAIL"
    case travel = "TRAVEL_TRANSPORTATION"
    
    var allCategories: [Categories] = {
        return [.arts, .education, .fitness, .food, .hotel, .medical, .shopping, .travel]
    }()
}

struct PlaceManager {
    fileprivate let placeManager: FBSDKPlacesManager
    
    init() {
        self.placeManager = FBSDKPlacesManager()
    }
    
    func getInfoAboutPlace(location: CLLocation) {
        let request = placeManager.placeSearchRequest(for: location,
                                                      searchTerm: nil,
                                                      categories: ["ARTS_ENTERTAINMENT",
                                                                   "EDUCATION",
                                                                   "FITNESS_RECREATION",
                                                                   "FOOD_BEVERAGE",
                                                                   "HOTEL_LODGING",
                                                                   "MEDICAL_HEALTH",
                                                                   "SHOPPING_RETAIL",
                                                                   "TRAVEL_TRANSPORTATION"],
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
                                                      distance: 1000,
                                                      cursor: nil)
        
        request?.start(completionHandler: { (_, data, error) in
            print(data as Any, error as Any)
        })
    }
}
