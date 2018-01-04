//
//  PlaceSetting.swift
//  Circle
//
//  Created by Kviatkovskii on 01/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
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
            return "Arts"
        case .education:
            return "Education"
        case .fitness:
            return "Fitness"
        case .food:
            return "Food"
        case .hotel:
            return "Hotel"
        case .medical:
            return "Medical"
        case .shopping:
            return "Shopping"
        case .travel:
            return "Travel"
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
