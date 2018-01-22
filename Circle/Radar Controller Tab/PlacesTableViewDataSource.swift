//
//  PlacesTableViewDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 02/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift

final class PlacesTableViewDataSource: NSObject {
    var places: [Places]
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    fileprivate var notificationTokenRating: NotificationToken?

    init(_ tableView: UITableView, places: [Places] = [], kingfisherOptions: KingfisherOptionsInfo) {
        self.places = places
        self.kingfisherOptions = kingfisherOptions
        super.init()
        tableView.dataSource = self
    }
}

extension PlacesTableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = places[indexPath.section].items[indexPath.row]
        let rating = places[indexPath.section].ratings[indexPath.row]
        let title = places[indexPath.section].titles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.cellIndetifier,
                                                 for: indexPath) as? PlaceTableViewCell ?? PlaceTableViewCell()
        
        cell.rating = rating
        cell.title = title
        cell.titleCategory = place.categories?.first?.title
        cell.colorCategory = place.categories?.first?.color
        cell.imageCell.kf.indicatorType = .activity
        cell.imageCell.kf.setImage(with: place.coverPhoto,
                                   placeholder: nil,
                                   options: self.kingfisherOptions,
                                   progressBlock: nil,
                                   completionHandler: nil)
        
        return cell
    }
}
