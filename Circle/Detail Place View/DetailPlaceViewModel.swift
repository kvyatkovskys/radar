//
//  DetailPlaceViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation
import RxSwift

struct DetailSectionObjects {
    var sectionName: String
    var sectionObjects: [TypeDetailCell]
}

struct DetailPlaceViewModel {
    var place: PlaceModel
    let title: NSMutableAttributedString?
    let rating: NSMutableAttributedString?
    var dataSource: [DetailSectionObjects]
    
    fileprivate let service: FavoritesService
    fileprivate let disposeBag = DisposeBag()

    init(_ place: PlaceModel, _ title: NSMutableAttributedString?, _ rating: NSMutableAttributedString?, _ service: FavoritesService) {
        self.service = service
        self.place = place
        self.title = title
        self.rating = rating
        self.dataSource = DetailPlaceViewModel.updateValue(place: place, colorCategory: place.categories?.first?.color)
    }
    
    func getInfoAboutPlace(id: Int) -> Observable<[DetailSectionObjects]> {
        return service.loadInfoPlace(id: id).flatMap({ (model) -> Observable<[DetailSectionObjects]> in
            return Observable.just(DetailPlaceViewModel.updateValue(place: model, colorCategory: self.place.categories?.first?.color))
        })
    }
    
    static fileprivate func updateValue(place: PlaceModel, colorCategory: UIColor?) -> [DetailSectionObjects] {
        var items: [DetailSectionObjects] = []
        
        if (place.phone != nil) || (place.website != nil) || (place.appLink != nil) {
            let itemsContact = [Contact(type: ContactType.phone, value: place.phone),
                                Contact(type: ContactType.website, value: place.website),
                                Contact(type: ContactType.facebook, value: place.appLink)]
            let type = TypeDetailCell.contact(itemsContact, 50.0)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        if let hours = place.hours {
            var closedDays: [Days] = []
            var openedDays: [Days] = []
            
            hours.filter({ $0.key.contains("1") }).forEach({ (key, value) in
                switch key {
                case _ where key.contains(DaysType.monday.shortName):
                    guard key.contains("close") else {
                        openedDays.append(Days(day: DaysType.monday, hour: value))
                        return
                    }
                    closedDays.append(Days(day: DaysType.monday, hour: value))
                case _ where key.contains(DaysType.tuesday.shortName):
                    guard key.contains("close") else {
                        openedDays.append(Days(day: DaysType.tuesday, hour: value))
                        return
                    }
                    closedDays.append(Days(day: DaysType.tuesday, hour: value))
                case _ where key.contains(DaysType.wednesday.shortName):
                    guard key.contains("close") else {
                        openedDays.append(Days(day: DaysType.wednesday, hour: value))
                        return
                    }
                    closedDays.append(Days(day: DaysType.wednesday, hour: value))
                case _ where key.contains(DaysType.thursday.shortName):
                    guard key.contains("close") else {
                        openedDays.append(Days(day: DaysType.thursday, hour: value))
                        return
                    }
                    closedDays.append(Days(day: DaysType.thursday, hour: value))
                case _ where key.contains(DaysType.friday.shortName):
                    guard key.contains("close") else {
                        openedDays.append(Days(day: DaysType.friday, hour: value))
                        return
                    }
                    closedDays.append(Days(day: DaysType.friday, hour: value))
                case _ where key.contains(DaysType.saturday.shortName):
                    guard key.contains("close") else {
                        openedDays.append(Days(day: DaysType.saturday, hour: value))
                        return
                    }
                    closedDays.append(Days(day: DaysType.saturday, hour: value))
                case _ where key.contains(DaysType.sunday.shortName):
                    guard key.contains("close") else {
                        openedDays.append(Days(day: DaysType.sunday, hour: value))
                        return
                    }
                    closedDays.append(Days(day: DaysType.sunday, hour: value))
                default:
                    break
                }
            })
            
            let sortedOpenedDays = Array(openedDays).sorted(by: { $0.day.sortIndex < $1.day.sortIndex })
            let sortedClosedDays = Array(closedDays).sorted(by: { $0.day.sortIndex < $1.day.sortIndex })
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat  = "EEEE"
            let dayInWeek = dateFormatter.string(from: date)
            let index = sortedOpenedDays.index(where: { $0.day.rawValue == dayInWeek })
            
            let type = TypeDetailCell.workDays((closed: sortedClosedDays,
                                                opened: sortedOpenedDays,
                                                currentDay: CurrentDay(index, colorCategory)),
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
                let type = TypeDetailCell.restaurantService(serviceType, 50.0, colorCategory)
                items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
            }
        }
        
        if let restaurantSpecialties = place.restaurantSpecialties {
            let specialityType = restaurantSpecialties.filter({ $0.value == true }).map({ RestaurantSpecialityType(rawValue: $0.key) })
            if !specialityType.isEmpty {
                let type = TypeDetailCell.restaurantSpeciality(specialityType, 50.0, colorCategory)
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
}