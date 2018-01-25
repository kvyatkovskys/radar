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
    let data: [PlaceModel]
    let next: URL?
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
    let name: String
    let phone: Int?
    let ratingStar: Float?
    let ratingCount: Int?
    let hours: [String: String]?
    let isAlwaysOpen: Bool?
    let isClosed: Bool?
    let address: String?
    let website: String?
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
}

extension PlaceModel: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.phone = unboxer.unbox(key: "phone")
        self.ratingStar = unboxer.unbox(key: "overall_star_rating")
        self.ratingCount = unboxer.unbox(key: "rating_count")
        self.hours = unboxer.unbox(key: "hours")
        self.isAlwaysOpen = unboxer.unbox(key: "is_always_open")
        self.isClosed = unboxer.unbox(key: "is_permanently_closed")
        self.address = unboxer.unbox(key: "single_line_address")
        self.website = unboxer.unbox(key: "website")
        let categories: [String] = try unboxer.unbox(key: "matched_categories")
        self.categories = categories.map({ Categories(rawValue: $0)! })
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
    }
}

struct LocationPlace {
    let coordinate: CLLocation
    let latitude: Double
    let longitude: Double
}

extension LocationPlace: Unboxable {
    init(unboxer: Unboxer) throws {
        self.latitude = try unboxer.unbox(key: "latitude")
        self.longitude = try unboxer.unbox(key: "longitude")
        self.coordinate = CLLocation(latitude: latitude, longitude: longitude)
    }
}
