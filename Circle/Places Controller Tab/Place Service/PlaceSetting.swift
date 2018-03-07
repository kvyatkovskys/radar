//
//  PlaceSetting.swift
//  Circle
//
//  Created by Kviatkovskii on 01/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import FBSDKPlacesKit

final class PlaceSetting {
    fileprivate var fileds: [String] = [FBSDKPlacesFieldKeyPlaceID,
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
                                        FBSDKPlacesFieldKeyLocation,
                                        FBSDKPlacesFieldKeyCategories,
                                        FBSDKPlacesFieldKeyAppLinks]
    
    var fields: [String] {
        guard FBSDKAccessToken.current() != nil else { return fileds }
        /**
         Field Key for the OpenGraphContext of the place, including friends who were at this
         place, or who liked to its page. This field requires authentication with a user token.
         An error will be thrown if this field is requested using a client token.
         */
        guard fileds.contains(FBSDKPlacesFieldKeyContext) else {
            fileds.append(FBSDKPlacesFieldKeyContext)
            return fileds
        }
        return fileds
    }
    
    var allCategories: [Categories] {
        return [.arts, .education, .fitness, .food, .hotel, .medical, .shopping, .travel]
    }
}

enum Categories: String {
    case arts = "ARTS_ENTERTAINMENT"
    case education = "EDUCATION"
    case fitness = "FITNESS_RECREATION"
    case food = "FOOD_BEVERAGE"
    case hotel = "HOTEL_LODGING"
    case medical = "MEDICAL_HEALTH"
    case shopping = "SHOPPING_RETAIL"
    case travel = "TRAVEL_TRANSPORTATION"
    
    var color: UIColor {
        switch self {
        case .arts:
            return UIColor.artsColor
        case .education:
            return UIColor.educationColor
        case .fitness:
            return UIColor.fitnessColor
        case .food:
            return UIColor.foodColor
        case .hotel:
            return UIColor.hotelColor
        case .medical:
            return UIColor.medicalColor
        case .shopping:
            return UIColor.shoppingColor
        case .travel:
            return UIColor.travelColor
        }
    }
    
    var title: String {
        switch self {
        case .arts:
            return NSLocalizedString("arts", comment: "Title for art category")
        case .education:
            return NSLocalizedString("education", comment: "Title for education category")
        case .fitness:
            return NSLocalizedString("fitness", comment: "Title for fitness category")
        case .food:
            return NSLocalizedString("food", comment: "Title for food category")
        case .hotel:
            return NSLocalizedString("hotel", comment: "Title for hotel category")
        case .medical:
            return NSLocalizedString("medical", comment: "Title for medical category")
        case .shopping:
            return NSLocalizedString("shopping", comment: "Title for shopping category")
        case .travel:
            return NSLocalizedString("travel", comment: "Title for travel category")
        }
    }
}

fileprivate extension UIColor {
    static var artsColor: UIColor {
        return UIColor(withHex: 0xe74c3c, alpha: 1.0)
    }
    
    static var educationColor: UIColor {
        return UIColor(withHex: 0x7f8c8d, alpha: 1.0)
    }
    
    static var fitnessColor: UIColor {
        return UIColor(withHex: 0xf1c40f, alpha: 1.0)
    }
    
    static var foodColor: UIColor {
        return UIColor(withHex: 0x1abc9c, alpha: 1.0)
    }
    
    static var hotelColor: UIColor {
        return UIColor(withHex: 0x8e44ad, alpha: 1.0)
    }
    
    static var medicalColor: UIColor {
        return UIColor(withHex: 0x27ae60, alpha: 1.0)
    }
    
    static var shoppingColor: UIColor {
        return UIColor(withHex: 0xe67e22, alpha: 1.0)
    }
    
    static var travelColor: UIColor {
        return UIColor(withHex: 0xf39c12, alpha: 1.0)
    }
}
