//
//  DetailPlaceModel.swift
//  Circle
//
//  Created by Kviatkovskii on 24/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import Unbox

struct DetailImagesModel {
    let data: [DetailDataImages]
    let next: String
}

extension DetailImagesModel: Unboxable {
    init(unboxer: Unboxer) throws {
        self.data = try unboxer.unbox(key: "data")
        self.next = try unboxer.unbox(keyPath: "paging.cursors.after")
    }
}

struct DetailDataImages {
    let id: Int
    let images: [Images]
    let picture: String
}

extension DetailDataImages: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.images = try unboxer.unbox(key: "images")
        self.picture = try unboxer.unbox(key: "picture")
    }
}

struct Images {
    let height: Int
    let width: Int
    let source: String
}

extension Images: Unboxable {
    init(unboxer: Unboxer) throws {
        self.height = try unboxer.unbox(key: "height")
        self.width = try unboxer.unbox(key: "width")
        self.source = try unboxer.unbox(key: "source")
    }
}

struct DetailPictureModel {
    let url: URL?
}

extension DetailPictureModel: Unboxable {
    init(unboxer: Unboxer) throws {
        let urlString: String? = unboxer.unbox(keyPath: "picture.data.url")
        self.url = urlString != nil ? URL(string: urlString ?? "") : nil
    }
}

enum RestaurantSpecialityType: String {
    case lunch, dinner, drinks, breakfast, coffee
    
    var title: String {
        switch self {
        case .breakfast: return NSLocalizedString("breakfast", comment: "Title for the restaurant speciality")
        case .lunch: return NSLocalizedString("lunch", comment: "Title for the restaurant speciality")
        case .dinner: return NSLocalizedString("dinner", comment: "Title for the restaurant speciality")
        case .drinks: return NSLocalizedString("drinks", comment: "Title for the restaurant speciality")
        case .coffee: return NSLocalizedString("coffee", comment: "Title for the restaurant speciality")
        }
    }
    
    var width: CGFloat {
        return self.title.width(font: .boldSystemFont(ofSize: 12.0), height: 25.0) + 25.0
    }
}

enum RestaurantServiceType: String {
    case groups, waiter, delivery, outdoor, kids, reserve, takeout, catering, walkins, pickup
    
    var title: String {
        switch self {
        case .catering: return NSLocalizedString("catering", comment: "Title for the restaurant service")
        case .groups: return NSLocalizedString("groups", comment: "Title for the restaurant service")
        case .waiter: return NSLocalizedString("waiter", comment: "Title for the restaurant service")
        case .delivery: return NSLocalizedString("delivery", comment: "Title for the restaurant service")
        case .outdoor: return NSLocalizedString("outdoor", comment: "Title for the restaurant service")
        case .kids: return NSLocalizedString("kids", comment: "Title for the restaurant service")
        case .reserve: return NSLocalizedString("reserve", comment: "Title for the restaurant service")
        case .takeout: return NSLocalizedString("takeout", comment: "Title for the restaurant service")
        case .walkins: return NSLocalizedString("walkins", comment: "Title for the restaurant service")
        case .pickup: return NSLocalizedString("pickup", comment: "Title for the restaurant service")
        }
    }
    
    var width: CGFloat {
        return self.title.width(font: .boldSystemFont(ofSize: 12.0), height: 25.0) + 25.0
    }
}

enum ParkingType: String {
    case lot, street, valet
    
    var title: String {
        switch self {
        case .lot: return NSLocalizedString("parkingLot", comment: "Title for the parking type")
        case .street: return NSLocalizedString("onStreet", comment: "Title for the parking type")
        case .valet: return NSLocalizedString("valetParking", comment: "Title for the parking type")
        }
    }
    
    var image: UIImage {
        switch self {
        case .lot: return (UIImage(named: "ic_place_parking")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate))!
        case .street: return (UIImage(named: "ic_parking")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate))!
        case .valet: return (UIImage(named: "ic_valet_parking")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate))!
        }
    }
    
    var width: CGFloat {
        return self.title.width(font: .systemFont(ofSize: 12.0), height: 15.0) + 20.0
    }
}

enum PaymentType: String {
    case cash = "cash_only", amex, visa, mastercard, discover
    
    var title: String {
        switch self {
        case .amex: return "AMEX"
        case .visa: return "VISA"
        case .cash: return NSLocalizedString("cash", comment: "Title for the payment type")
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
    
    var width: CGFloat {
        return self.title.width(font: .systemFont(ofSize: 12.0), height: 15.0) + 20.0
    }
}

enum ContactType: String {
    case phone, website, facebook
    
    var title: String {
        switch self {
        case .facebook: return "Facebook"
        case .phone: return NSLocalizedString("call", comment: "Title for the contact type")
        case .website: return NSLocalizedString("website", comment: "Title for the contact type")
        }
    }
    
    var image: UIImage {
        switch self {
        case .facebook: return (UIImage(named: "ic_facebook")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate))!
        case .phone: return (UIImage(named: "ic_phone")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate))!
        case .website: return (UIImage(named: "ic_web")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate))!
        }
    }
    
    var width: CGFloat {
        return self.title.width(font: .boldSystemFont(ofSize: 14.0), height: 15.0) + 50.0
    }
}

typealias Contact = (type: ContactType, value: Any?)

enum DaysType: String {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var title: String {
        switch self {
        case .monday: return NSLocalizedString("monday", comment: "Title for the day type")
        case .tuesday: return NSLocalizedString("tuesday", comment: "Title for the day type")
        case .wednesday: return NSLocalizedString("wednesday", comment: "Title for the day type")
        case .thursday: return NSLocalizedString("thursday", comment: "Title for the day type")
        case .friday: return NSLocalizedString("friday", comment: "Title for the day type")
        case .saturday: return NSLocalizedString("saturday", comment: "Title for the day type")
        case .sunday: return NSLocalizedString("sunday", comment: "Title for the day type")
        }
    }
    
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
    
    var width: CGFloat {
        return self.title.width(font: .systemFont(ofSize: 14.0), height: 15.0) + 30.0
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
    case images([Images], [URL?], String, CGFloat)
    
    var title: String {
        switch self {
        case .workDays: return NSLocalizedString("openHours", comment: "Title for the cell type")
        case .description: return NSLocalizedString("description", comment: "Title for the cell type")
        case .contact: return NSLocalizedString("contacts", comment: "Title for the cell type")
        case .address: return NSLocalizedString("address", comment: "Title for the cell type")
        case .payment: return NSLocalizedString("payment", comment: "Title for the cell type")
        case .parking: return NSLocalizedString("parking", comment: "Title for the cell type")
        case .restaurantService: return NSLocalizedString("restaurantService", comment: "Title for the cell type")
        case .restaurantSpeciality: return NSLocalizedString("restaurantSpecialties", comment: "Title for the cell type")
        case .images: return NSLocalizedString("photos", comment: "Title for the cell type")
        }
    }
}
