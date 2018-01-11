//
//  PlaceViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 01/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

struct PlacesSections {
    let sections: [[Categories]]
    let places: [[PlaceModel]]
    let ratings: [[NSMutableAttributedString?]]
    let titles: [[NSMutableAttributedString?]]
    
    init(_ places: [[PlaceModel]], _ sections: [[Categories]], _ ratings: [[NSMutableAttributedString?]], _ titles: [[NSMutableAttributedString?]]) {
        self.places = places
        self.sections = sections
        self.ratings = ratings
        self.titles = titles
    }
}

struct PlaceViewModel {
    fileprivate let placeService: PlaceService
    /// open filter controller
    var openFilter: ((_ delegate: FilterPlacesDelegate) -> Void)?
    
    /// open choose categories controller
    var openCategories: (() -> Void)?
    
    init(_ service: PlaceService) {
        self.placeService = service
    }
    
    /// get info about for current location
    func getInfoPlace(location: CLLocation, distance: CLLocationDistance) -> Observable<PlacesSections> {
        var selected: [Categories] = [.arts, .education, .fitness, .food, .hotel, .medical, .shopping, .travel]
        do {
            let realm = try Realm()
            let selectedCategories = realm.objects(FilterSelectedCategory.self)
            if !selectedCategories.isEmpty {
                selected = selectedCategories.map({ Categories(rawValue: $0.category)! })
            }
        } catch {
            print(error)
        }
        
        return placeService.getInfoAboutPlace(location, selected, distance)
            .asObservable().flatMap { (model) -> Observable<PlacesSections> in
                let sections = model.map({ $0.categories })
                let uniqueSections = sections.reduce([], { (acc: [[Categories]], element) in
                    var unique: [[Categories]]
                    let contains = acc.contains(where: { $0 == (element ?? []) })
                    if contains {
                        unique = acc
                    } else {
                        unique = acc + [(element ?? [])]
                    }
                    return unique
                }).sorted(by: { (itemOne, itemTwo) -> Bool in
                    return (itemOne.first?.title ?? "") < (itemTwo.first?.title ?? "")
                })
                
                var placesFilter: [[PlaceModel]] = []
                var ratingsFilter: [[NSMutableAttributedString?]] = []
                var titlesFilter: [[NSMutableAttributedString?]] = []
                
                uniqueSections.forEach({ (section) in
                    let places = model.filter({ ($0.categories ?? []) == section })
                    placesFilter += [places]
                    
                    let ratings = places.map({ (place) -> NSMutableAttributedString? in
                        let ratingStar = NSAttributedString(string: "\(place.ratingStar ?? 0)",
                            attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17.0),
                                         NSAttributedStringKey.foregroundColor: UIColor.black])
                        let ratingCount = NSAttributedString(string: " \(place.ratingCount ?? 0)",
                            attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0),
                                         NSAttributedStringKey.foregroundColor: UIColor.gray])
                        
                        let result = NSMutableAttributedString(attributedString: ratingStar)
                        result.append(ratingCount)
                        return result
                    })
                    ratingsFilter += [ratings]
                    
                    let titles = places.map({ (place) -> NSMutableAttributedString? in
                        let title = NSAttributedString(string: "\(place.name)",
                            attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17.0),
                                         NSAttributedStringKey.foregroundColor: UIColor.black])
                        let about = NSAttributedString(string: "\n\n\(place.about ?? "")",
                            attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0),
                                         NSAttributedStringKey.foregroundColor: UIColor.gray])
                        
                        let result = NSMutableAttributedString(attributedString: title)
                        result.append(about)
                        return result
                    })
                    titlesFilter += [titles]
                })
                return Observable.just(PlacesSections(placesFilter, uniqueSections, ratingsFilter, titlesFilter))
        }
    }
}
