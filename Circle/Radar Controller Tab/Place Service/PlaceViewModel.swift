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

typealias Place = (info: PlaceModel, title: NSMutableAttributedString?, rating: NSMutableAttributedString?)

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
    var openFilter: ((_ delegate: FilterPlacesDelegate) -> Void) = {_ in }
    
    /// open map controller
    var openMap: ((_ places: [Places], _ location: CLLocation?, _ sourceRect: CGRect) -> Void) = {_, _, _ in }
    
    /// open detail place controller
    var openDetailPlace: ((_ place: Place) -> Void) = {_ in }
    
    init(_ service: PlaceService) {
        self.placeService = service
    }
    
    func loadMoreInfoPlaces(url: URL) -> Observable<Places> {
        return placeService.loadMorePlaces(url: url).asObservable()
            .flatMap({ (model) -> Observable<Places> in
                let (places, ratings, titles) = self.updateResults(model: model)
                return Observable.just(Places(places, ratings, titles, model.next))
            })
    }
    
    /// get info about for current location
    func getInfoPlaces(location: CLLocation, distance: CLLocationDistance) -> Observable<Places> {
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
        
        return placeService.getInfoAboutPlaces(location, selected, distance)
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
    
    //swiftlint:disable large_tuple
    fileprivate func updateResults(model: PlaceDataModel) -> ([PlaceModel], [NSMutableAttributedString?], [NSMutableAttributedString?]) {
        var rating: TypeRating? = TypeRating.none
        
        do {
            let realm = try Realm()
            let selectedRating = realm.objects(FilterSelectedRating.self).first
            if let type = selectedRating {
                rating = TypeRating(rawValue: type.rating)
            }
        } catch {
            print(error)
        }
        
        let places = model.data.sorted(by: { (itemOne, itemTwo) -> Bool in
            guard rating != TypeRating.none else { return false }
            guard rating == TypeRating.up else {
                return (itemOne.ratingStar ?? 0) < (itemTwo.ratingStar ?? 0)
            }
            return (itemOne.ratingStar ?? 0) > (itemTwo.ratingStar ?? 0)
        })
        
        let ratings = places.map({ (place) -> NSMutableAttributedString? in
            let ratingStar = NSAttributedString(string: "\(place.ratingStar ?? 0)",
                attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17.0),
                             NSAttributedStringKey.foregroundColor: self.colorForRating(place.ratingStar ?? 0)])
            let ratingCount = NSAttributedString(string: " \(place.ratingCount ?? 0)",
                attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0),
                             NSAttributedStringKey.foregroundColor: UIColor.gray])
            
            let result = NSMutableAttributedString(attributedString: ratingStar)
            result.append(ratingCount)
            return result
        })
        
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
        return (places, ratings, titles)
    }
}
