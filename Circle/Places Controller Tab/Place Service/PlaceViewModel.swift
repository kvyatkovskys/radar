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

struct Places {
    let items: [PlaceModel]
    let ratings: [NSMutableAttributedString?]
    let titles: [NSMutableAttributedString?]
    let next: URL?
    
    init(_ places: [PlaceModel] = [], _ ratings: [NSMutableAttributedString?] = [], _ titles: [NSMutableAttributedString?] = [], _ next: URL? = nil) {
        self.items = places
        self.ratings = ratings
        self.titles = titles
        self.next = next
    }
}

struct PlaceViewModel {
    fileprivate let placeService: PlaceService
    /// open filter controller
    var openFilter: (() -> Void) = { UIImpactFeedbackGenerator().impactOccurred() }
    
    /// open map controller
    var openMap: (([Places], CLLocation?) -> Void) = {_, _ in UIImpactFeedbackGenerator().impactOccurred() }
    
    /// open detail place controller
    var openDetailPlace: ((PlaceModel, NSMutableAttributedString?, NSMutableAttributedString?, FavoritesViewModel) -> Void) = {_, _, _, _ in }
    
    init(_ service: PlaceService) {
        self.placeService = service
    }
    
    func getPlacesFirMinDistance() -> Observable<Places> {
        return placeService.loadPlacesForMinDistance().asObservable()
            .flatMap({ (model) -> Observable<Places> in
                let (places, ratings, titles) = self.updateResults(model: model)
                return Observable.just(Places(places, ratings, titles, model.next))
            })
    }
    
    /// load more places
    func getMorePlaces(url: URL) -> Observable<Places> {
        return placeService.loadMorePlaces(url: url).asObservable()
            .flatMap({ (model) -> Observable<Places> in
                let (places, ratings, titles) = self.updateResults(model: model)
                return Observable.just(Places(places, ratings, titles, model.next))
            })
    }
    
    /// get info about for current location
    func getPlaces(location: CLLocation?, distance: CLLocationDistance, searchTerm: String? = nil) -> Observable<Places> {
        var categories = PlaceSetting().allCategories
        
        if searchTerm == nil {
            do {
                let realm = try Realm()
                let selectedCategories = realm.objects(FilterSelectedCategory.self)
                if !selectedCategories.isEmpty {
                    categories = selectedCategories.map({ Categories(rawValue: $0.category)! })
                }
            } catch {
                print(error)
            }
        }
        
        return placeService.loadPlaces(location, categories, distance, searchTerm)
            .asObservable().flatMap { (model) -> Observable<Places> in
                let (places, ratings, titles) = self.updateResults(model: model)
                return Observable.just(Places(places, ratings, titles, model.next))
        }
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
    
    fileprivate func updateResults(model: PlaceDataModel) -> ([PlaceModel], [NSMutableAttributedString?], [NSMutableAttributedString?]) {
        let ratings = model.data.map({ (place) -> NSMutableAttributedString? in
            let ratingStar = NSAttributedString(string: "\(place.ratingStar ?? 0)",
                attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0),
                             NSAttributedStringKey.foregroundColor: self.colorForRating(place.ratingStar ?? 0)])
            let ratingCount = NSAttributedString(string: " \(place.ratingCount ?? 0)",
                attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0),
                             NSAttributedStringKey.foregroundColor: UIColor.gray])
            
            let result = NSMutableAttributedString(attributedString: ratingStar)
            result.append(ratingCount)
            return result
        })
        
        let titles = model.data.map({ (place) -> NSMutableAttributedString? in
            let title = NSAttributedString(string: "\(place.name ?? "")",
                attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17.0),
                             NSAttributedStringKey.foregroundColor: UIColor.black])
            let about = NSAttributedString(string: "\n\n\(place.about ?? "")",
                attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0),
                             NSAttributedStringKey.foregroundColor: UIColor.gray])
            
            let result = NSMutableAttributedString(attributedString: title)
            result.append(about)
            return result
        })
        return (model.data, ratings, titles)
    }
}
