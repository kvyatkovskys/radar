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
}

extension PlaceDataModel: Unboxable {
    init(unboxer: Unboxer) throws {
        self.data = try unboxer.unbox(key: "data")
    }
}

struct PlaceModel {
    let id: Int
    let name: String
    let phone: Int?
    let rating: Float?
    let address: String?
    let website: String?
    let categories: [Categories]?
    let description: String?
    let coverPhoto: CoverPhotoPlace?
    let about: String?
    let location: LocationPlace?
}

extension PlaceModel: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.phone = unboxer.unbox(key: "phone")
        self.rating = unboxer.unbox(key: "overall_star_rating")
        self.address = unboxer.unbox(key: "single_line_address")
        self.website = unboxer.unbox(key: "website")
        let categories: [String] = try unboxer.unbox(key: "matched_categories")
        self.categories = categories.map({ Categories(rawValue: $0)! })
        self.description = unboxer.unbox(key: "description")
        self.coverPhoto = unboxer.unbox(key: "cover")
        self.about = unboxer.unbox(key: "about")
        self.location = unboxer.unbox(key: "location")
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

struct CoverPhotoPlace {
    let url: URL?
}

extension CoverPhotoPlace: Unboxable {
    init(unboxer: Unboxer) throws {
        self.url = URL(string: try unboxer.unbox(key: "source"))
    }
}
