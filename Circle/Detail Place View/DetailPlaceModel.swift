//
//  DetailPlaceModel.swift
//  Circle
//
//  Created by Kviatkovskii on 24/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import Unbox

struct DetailServiceModel {
    let url: URL?
}

extension DetailServiceModel: Unboxable {
    init(unboxer: Unboxer) throws {
        let urlString: String? = unboxer.unbox(keyPath: "picture.data.url")
        self.url = urlString != nil ? URL(string: urlString ?? "") : nil
    }
}

enum RestaurantSpecialityType: String {
    case lunch, dinner, drinks, breakfast, coffee
    
    var title: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .drinks: return "Drinks"
        case .coffee: return "Coffee"
        }
    }
    
    var width: CGFloat {
        switch self {
        case .breakfast, .coffee, .dinner, .drinks, .lunch:
            return self.rawValue.width(font: .boldSystemFont(ofSize: 12.0), height: 25.0) + 25.0
        }
    }
}

enum RestaurantServiceType: String {
    case groups, waiter, delivery, outdoor, kids, reserve, takeout, catering, walkins, pickup
    
    var title: String {
        switch self {
        case .catering: return "Catering"
        case .groups: return "Groups"
        case .waiter: return "Waiter"
        case .delivery: return "Delivery"
        case .outdoor: return "Outdoor"
        case .kids: return "Kids"
        case .reserve: return "Reserve"
        case .takeout: return "Takeout"
        case .walkins: return "Walkins"
        case .pickup: return "Pickup"
        }
    }
    
    var width: CGFloat {
        switch self {
        case .catering, .groups, .waiter, .delivery, .outdoor, .kids, .reserve, .takeout, .walkins, .pickup:
            return self.rawValue.width(font: .boldSystemFont(ofSize: 12.0), height: 25.0) + 25.0
        }
    }
}

enum ParkingType: String {
    case lot, street, valet
    
    var title: String {
        switch self {
        case .lot: return "Parking lot"
        case .street: return "On-street"
        case .valet: return "Valet parking"
        }
    }
    
    var image: UIImage {
        switch self {
        case .lot: return (UIImage(named: "ic_place_parking")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))!
        case .street: return (UIImage(named: "ic_parking")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))!
        case .valet: return (UIImage(named: "ic_valet_parking")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))!
        }
    }
}

enum PaymentType: String {
    case cash = "cash_only", amex, visa, mastercard, discover
    
    var title: String {
        switch self {
        case .amex: return "AMEX"
        case .visa: return "VISA"
        case .cash: return "Cash"
        case .discover: return "Discover"
        case .mastercard: return "Mastercard"
        }
    }
    
    var image: UIImage {
        switch self {
        case .amex: return UIImage(named: "ic_amex")!
        case .cash: return UIImage(named: "ic_money")!
        case .discover: return UIImage(named: "ic_discover")!
        case .mastercard: return UIImage(named: "ic_mastercard")!
        case .visa: return UIImage(named: "ic_visa")!
        }
    }
    
}

enum ContactType: String {
    case phone, website, facebook
    
    var title: String {
        switch self {
        case .facebook: return "Facebook"
        case .phone: return "Call"
        case .website: return "Website"
        }
    }
    
    var image: UIImage {
        switch self {
        case .facebook: return (UIImage(named: "ic_facebook")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))!
        case .phone: return (UIImage(named: "ic_phone")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))!
        case .website: return (UIImage(named: "ic_web")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))!
        }
    }
}

typealias Contact = (type: ContactType, value: Any?)

enum DaysType: String {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var shortName: String {
        switch self {
        case .monday: return "mon"
        case .tuesday: return "tue"
        case .wednesday: return "wed"
        case .thursday: return "thu"
        case .friday: return "fri"
        case .saturday: return "sat"
        case .sunday: return "sun"
        }
    }
    
    var sortIndex: Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        case .saturday: return 5
        case .sunday: return 6
        }
    }
}

typealias Days = (day: DaysType, hour: String)
typealias CurrentDay = (index: Int?, color: UIColor?)
typealias WorkDays = (closed: [Days], opened: [Days], currentDay: CurrentDay)

enum TypeDetailCell {
    case description(String, CGFloat)
    case contact([Contact], CGFloat)
    case address(String, LocationPlace?, CGFloat)
    case workDays(WorkDays, CGFloat)
    case payment([PaymentType?], CGFloat)
    case parking([ParkingType?], CGFloat)
    case restaurantService([RestaurantServiceType?], CGFloat, UIColor?)
    case restaurantSpeciality([RestaurantSpecialityType?], CGFloat, UIColor?)
    
    var title: String {
        switch self {
        case .workDays: return "Openig hours"
        case .description: return "Description"
        case .contact: return "Contacts"
        case .address: return "Address"
        case .payment: return "Payment"
        case .parking: return "Parking"
        case .restaurantService: return "Restaurant service"
        case .restaurantSpeciality: return "Restaurant specialties"
        }
    }
}
