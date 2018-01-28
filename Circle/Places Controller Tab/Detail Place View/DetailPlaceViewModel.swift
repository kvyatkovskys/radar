//
//  DetailPlaceViewModel.swift
//  Circle
//
//  Created by Kviatkovskii on 17/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

struct DetailSectionObjects {
    var sectionName: String
    var sectionObjects: [TypeDetailCell]
}

struct DetailPlaceViewModel {
    let place: Place
    var dataSource: [DetailSectionObjects]

    init(_ place: Place) {
        self.place = place
        var items: [DetailSectionObjects] = []
        
        if (place.info.phone != nil) || (place.info.website != nil) || (place.info.appLink != nil) {
            let itemsContact = [Contact(type: ContactType.phone, value: place.info.phone),
                                Contact(type: ContactType.website, value: place.info.website),
                                Contact(type: ContactType.facebook, value: place.info.appLink)]
            let type = TypeDetailCell.contact(itemsContact, 50.0)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        if let hours = place.info.hours {
            var closedDays: [Days] = []
            var openedDays: [Days] = []
            
            hours.forEach({ (key, value) in
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
                                                currentDay: CurrentDay(index, place.info.categories?.first?.color)),
                                               90.0)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        if let address = place.info.address {
            let height = address.height(font: .boldSystemFont(ofSize: 15.0),
                                        width: ScreenSize.SCREEN_WIDTH) + 80.0
            let type = TypeDetailCell.address(address, place.info.location, height)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        if let payments = place.info.paymentOptions {
            let paymentsType = payments.filter({ $0.value == true }).map({ PaymentType(rawValue: $0.key) })
            if !paymentsType.isEmpty {
                let type = TypeDetailCell.payment(paymentsType, 70.0)
                items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
            }
        }
        
        if let parking = place.info.parking {
            let parkingType = parking.filter({ $0.value == true }).map({ ParkingType(rawValue: $0.key) })
            if !parkingType.isEmpty {
                let type = TypeDetailCell.parking(parkingType, 70.0)
                items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
            }
        }
        
        if let restaurantService = place.info.restaurantServices {
            let serviceType = restaurantService.filter({ $0.value == true }).map({ RestaurantServiceType(rawValue: $0.key) })
            if !serviceType.isEmpty {
                let type = TypeDetailCell.restaurantService(serviceType, 50.0, place.info.categories?.first?.color)
                items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
            }
        }
        
        if let restaurantSpecialties = place.info.restaurantSpecialties {
            let specialityType = restaurantSpecialties.filter({ $0.value == true }).map({ RestaurantSpecialityType(rawValue: $0.key) })
            if !specialityType.isEmpty {
                let type = TypeDetailCell.restaurantSpeciality(specialityType, 50.0, place.info.categories?.first?.color)
                items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
            }
        }
        
        if let description = place.info.description {
            let height = description.height(font: .systemFont(ofSize: 14.0),
                                            width: ScreenSize.SCREEN_WIDTH)
            let type = TypeDetailCell.description(description, height)
            items.append(DetailSectionObjects(sectionName: type.title, sectionObjects: [type]))
        }
        
        self.dataSource = items
    }
}
