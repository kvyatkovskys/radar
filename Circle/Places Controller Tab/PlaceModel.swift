//
//  PlaceModel.swift
//  Circle
//
//  Created by Kviatkovskii on 31/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import Foundation
import Unbox

struct PlaceDataModel {
    var data: [PlaceModel]
    var next: URL?
}

extension PlaceDataModel: Unboxable {
    init(unboxer: Unboxer) throws {
        self.data = try unboxer.unbox(key: "data")
        let paging: [String: Any]? = unboxer.unbox(keyPath: "paging")
        self.next = paging != nil ? URL(string: paging!["next"] as? String ?? "") : nil
    }
}

struct PlaceModel {
    let id: Int
    let name: String?
    let phone: String?
    let ratingStar: Float?
    let ratingCount: Int?
    var rating: NSMutableAttributedString? {
        let ratingStar = NSAttributedString(string: "\(self.ratingStar ?? 0)",
            attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 19.0),
                         NSAttributedString.Key.foregroundColor: self.colorForRating(self.ratingStar ?? 0)])
        let ratingCount = NSAttributedString(string: " \(self.ratingCount ?? 0)",
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0),
                         NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        let result = NSMutableAttributedString(attributedString: ratingStar)
        result.append(ratingCount)
        return result
    }
    var title: NSMutableAttributedString? {
        let title = NSAttributedString(string: "\(self.name ?? "")",
            attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 19.0),
                         NSAttributedString.Key.foregroundColor: UIColor.black])
        let about = NSAttributedString(string: "\n\n\(self.about ?? "")",
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0),
                         NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        let result = NSMutableAttributedString(attributedString: title)
        result.append(about)
        return result
    }
    let hours: [[String: String]]?
    let isAlwaysOpen: Bool?
    let isClosed: Bool?
    let address: String?
    var website: String?
    let categories: [Categories]?
    let subCategories: [String]?
    let description: String?
    let coverPhoto: URL?
    let about: String?
    let location: LocationPlace?
    let context: String?
    let appLink: URL?
    let paymentOptions: [String: Bool]?
    let parking: [String: Bool]?
    let restaurantServices: [String: Bool]?
    let restaurantSpecialties: [String: Bool]?
    let fromFavorites: Bool
    
    init(id: Int, name: String? = nil, phone: String? = nil, ratingStar: Float? = nil, ratingCount: Int? = nil, hours: [[String: String]]? = nil,
         isAlwaysOpen: Bool? = nil, isClosed: Bool? = nil, address: String? = nil, website: String? = nil, categories: [Categories]? = nil,
         subCategories: [String]? = nil, description: String? = nil, coverPhoto: URL? = nil, about: String? = nil, location: LocationPlace? = nil,
         context: String? = nil, appLink: URL? = nil, paymentOptions: [String: Bool]? = nil, parking: [String: Bool]? = nil,
         restaurantServices: [String: Bool]? = nil, restaurantSpecialties: [String: Bool]? = nil, fromFavorites: Bool) {
        self.id = id
        self.name = name
        self.phone  = phone
        self.ratingStar = ratingStar
        self.ratingCount = ratingCount
        self.hours = hours
        self.isAlwaysOpen = isAlwaysOpen
        self.isClosed = isClosed
        self.address = address
        self.website = website
        self.categories = categories
        self.subCategories = subCategories
        self.description = description
        self.coverPhoto = coverPhoto
        self.about = about
        self.location = location
        self.context = context
        self.appLink = appLink
        self.paymentOptions = paymentOptions
        self.parking = parking
        self.restaurantServices = restaurantServices
        self.restaurantSpecialties = restaurantSpecialties
        self.fromFavorites = fromFavorites
    }
    
    fileprivate func colorForRating(_ rating: Float) -> UIColor {
        var color = UIColor()
        switch rating {
        case 3.4...5.0:
            color = UIColor(withHex: 0x2ecc71, alpha: 1.0)
        case 1.8...3.4:
            color = .black
        default:
            color = UIColor(withHex: 0xc0392b, alpha: 1.0)
        }
        return color
    }
}

extension PlaceModel: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.name = unboxer.unbox(key: "name")
        self.phone = unboxer.unbox(key: "phone")
        self.ratingStar = unboxer.unbox(key: "overall_star_rating")
        self.ratingCount = unboxer.unbox(key: "rating_count")
        self.hours = unboxer.unbox(key: "hours")
        self.isAlwaysOpen = unboxer.unbox(key: "is_always_open")
        self.isClosed = unboxer.unbox(key: "is_permanently_closed")
        self.address = unboxer.unbox(key: "single_line_address")
        self.website = unboxer.unbox(key: "website")
        let categories: [String]? = unboxer.unbox(key: "matched_categories")
        self.categories = (categories ?? []).map({ Categories(rawValue: $0)! })
        let subCategories: [[String: Any]] = try unboxer.unbox(key: "category_list")
        self.subCategories = subCategories.map({ $0["name"] }) as? [String]
        self.description = unboxer.unbox(key: "description")
        let photo: String? = unboxer.unbox(keyPath: "cover.source")
        self.coverPhoto = photo != nil ? URL(string: photo ?? "") : nil
        self.about = unboxer.unbox(key: "about")
        self.location = unboxer.unbox(key: "location")
        self.context = unboxer.unbox(keyPath: "context.id")
        let appLinks: [[String: Any]] = try unboxer.unbox(keyPath: "app_links.ios")
        self.appLink = URL(string: appLinks.filter({ "\($0["app_name"] ?? "")" == "Facebook" }).first?["url"] as? String ?? "")
        self.paymentOptions = unboxer.unbox(key: "payment_options")
        self.parking = unboxer.unbox(key: "parking")
        self.restaurantServices = unboxer.unbox(key: "restaurant_services")
        self.restaurantSpecialties = unboxer.unbox(key: "restaurant_specialties")
        self.fromFavorites = false
    }
}

struct LocationPlace {
    let coordinate: CLLocation
    let latitude: Double
    let longitude: Double
    let city: String
    let country: String
    let street: String
    let zip: String?
    let state: String?
}

extension LocationPlace: Unboxable {
    init(unboxer: Unboxer) throws {
        self.city = try unboxer.unbox(key: "city")
        self.country = try unboxer.unbox(key: "country")
        self.street = try unboxer.unbox(key: "street")
        self.zip = unboxer.unbox(key: "zip")
        self.state = unboxer.unbox(key: "state")
        self.latitude = try unboxer.unbox(key: "latitude")
        self.longitude = try unboxer.unbox(key: "longitude")
        self.coordinate = CLLocation(latitude: latitude, longitude: longitude)
    }
}
