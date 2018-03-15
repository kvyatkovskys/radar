//
//  DetailPlaceViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

struct DetailSectionObjects {
    var sectionName: String
    var sectionObjects: [TypeDetailCell]
}

struct DetailPlaceViewModel {    
    var place: PlaceModel
    let title: NSMutableAttributedString?
    let rating: NSMutableAttributedString?
    var dataSource: [DetailSectionObjects]
        
    fileprivate let colorCategory: UIColor?
    fileprivate let favoritesService: FavoritesService
    fileprivate let detailService = DetailService()
    fileprivate let disposeBag = DisposeBag()

    init(_ place: PlaceModel, _ title: NSMutableAttributedString?, _ rating: NSMutableAttributedString?, _ favoritesService: FavoritesService) {
        self.favoritesService = favoritesService
        self.place = place
        self.title = title
        self.rating = rating
        
        if (place.categories ?? []).isEmpty {
            colorCategory = UIColor.mainColor
        } else {
            colorCategory = place.categories?.first?.color
        }
        
        self.dataSource = DetailPlaceViewModel.updateValue(place: place, color: colorCategory)
    }
    
    mutating func loadPhotos() -> Observable<DetailSectionObjects> {
        return detailService.loadPhotos(id: place.id).asObservable()
            .filter({ !$0.data.isEmpty })
            .flatMap { (model) -> Observable<DetailSectionObjects> in
                let images = model.data.flatMap({ $0.images.first })
                let previews = model.data.map({ URL(string: $0.images.last?.source ?? "") })
                let nextImages = model.next
                let type = TypeDetailCell.images(images, previews, nextImages, 90.0)
                return Observable.just(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
    }
    
    func loadMorePhotos(url: URL) -> Observable<PageImages> {
        return detailService.loadMorePhotos(url: url).asObservable()
            .filter({ !$0.data.isEmpty })
            .flatMap { (model) -> Observable<PageImages> in
                let images = model.data.flatMap({ $0.images.first })
                let previews = model.data.map({ URL(string: $0.images.last?.source ?? "") })
                let nextImages = model.next
                return Observable.just(PageImages(images, previews, nextImages, nil))
        }
    }
    
    func getPictureProfile() -> Observable<URL?> {
        return detailService.loadPicture(id: place.id).asObservable()
            .flatMap { (url) -> Observable<URL?> in
                return Observable.just(url)
        }
    }
    
    func getInfoAboutPlace(id: Int) -> Observable<[DetailSectionObjects]> {
        return favoritesService.loadInfoPlace(id: id).flatMap({ (model) -> Observable<[DetailSectionObjects]> in
            if self.place.fromFavorites {
                 self.updateCoverPhoto(url: model.coverPhoto)
            }
            return Observable.just(DetailPlaceViewModel.updateValue(place: model, color: self.colorCategory))
        })
    }
    
    fileprivate func updateCoverPhoto(url: URL?) {
        do {
            let realm = try Realm()
            let favorites = realm.objects(Favorites.self).filter("id = \(place.id)").first
            try realm.write {
                favorites?.picture = url?.absoluteString
            }
        } catch {
            print(error)
        }
    }
    
    static fileprivate func updateValue(place: PlaceModel, color: UIColor?) -> [DetailSectionObjects] {
        var items: [DetailSectionObjects] = []
        
        if (place.phone != nil) || (place.website != nil) || (place.appLink != nil) {
            let itemsContact = [Contact(type: ContactType.phone, value: place.phone),
                                Contact(type: ContactType.website, value: place.website),
                                Contact(type: ContactType.facebook, value: place.appLink)]
            let type = TypeDetailCell.contact(itemsContact, 50.0)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        if let hours = place.hours {
            let closedDays: [Days] = hours.filter({ $0.key.contains("1") && $0.key.contains("close") })
                .flatMap({ DetailPlaceViewModel.getWorkDays($0.key, $0.value) })
                .sorted(by: { $0.day.sortIndex < $1.day.sortIndex })
            
            let openedDays: [Days] = hours.filter({ $0.key.contains("1") && $0.key.contains("open") })
                .flatMap({ DetailPlaceViewModel.getWorkDays($0.key, $0.value) })
                .sorted(by: { $0.day.sortIndex < $1.day.sortIndex })
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let dayInWeek = dateFormatter.string(from: date)
            let index = openedDays.index(where: { $0.day.title == dayInWeek.capitalizedFirstSymbol })
            
            let type = TypeDetailCell.workDays((closed: closedDays,
                                                opened: openedDays,
                                                currentDay: CurrentDay(index, color)),
                                               90.0)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        if let street = place.location?.street, let city = place.location?.city {
            let height = (city + " - " + street).height(font: .boldSystemFont(ofSize: 15.0),
                                                        width: ScreenSize.SCREEN_WIDTH) + 60.0
            let type = TypeDetailCell.address(city + " - " + street, place.location, height)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        if let payments = place.paymentOptions {
            let paymentsType = payments.filter({ $0.value == true }).map({ PaymentType(rawValue: $0.key) })
            if !paymentsType.isEmpty {
                let type = TypeDetailCell.payment(paymentsType, 70.0)
                items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
            }
        }
        
        if let parking = place.parking {
            let parkingType = parking.filter({ $0.value == true }).map({ ParkingType(rawValue: $0.key) })
            if !parkingType.isEmpty {
                let type = TypeDetailCell.parking(parkingType, 70.0)
                items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
            }
        }
        
        if let restaurantService = place.restaurantServices {
            let serviceType = restaurantService.filter({ $0.value == true }).map({ RestaurantServiceType(rawValue: $0.key) })
            if !serviceType.isEmpty {
                let type = TypeDetailCell.restaurantService(serviceType, 50.0, color)
                items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
            }
        }
        
        if let restaurantSpecialties = place.restaurantSpecialties {
            let specialityType = restaurantSpecialties.filter({ $0.value == true }).map({ RestaurantSpecialityType(rawValue: $0.key) })
            if !specialityType.isEmpty {
                let type = TypeDetailCell.restaurantSpeciality(specialityType, 50.0, color)
                items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
            }
        }
        
        if let description = place.description {
            let height = description.height(font: .systemFont(ofSize: 14.0),
                                            width: ScreenSize.SCREEN_WIDTH)
            let type = TypeDetailCell.description(description, height)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        return items
    }
    
    static fileprivate func getWorkDays(_ key: String, _ value: String) -> [Days] {
        var days: [Days] = []
        switch key {
        case _ where key.contains(DaysType.monday.shortName):
            days.append(Days(day: DaysType.monday, hour: value))
        case _ where key.contains(DaysType.tuesday.shortName):
            days.append(Days(day: DaysType.tuesday, hour: value))
        case _ where key.contains(DaysType.wednesday.shortName):
            days.append(Days(day: DaysType.wednesday, hour: value))
        case _ where key.contains(DaysType.thursday.shortName):
            days.append(Days(day: DaysType.thursday, hour: value))
        case _ where key.contains(DaysType.friday.shortName):
            days.append(Days(day: DaysType.friday, hour: value))
        case _ where key.contains(DaysType.saturday.shortName):
            days.append(Days(day: DaysType.saturday, hour: value))
        case _ where key.contains(DaysType.sunday.shortName):
            days.append(Days(day: DaysType.sunday, hour: value))
        default:
            break
        }
        return days
    }
}
