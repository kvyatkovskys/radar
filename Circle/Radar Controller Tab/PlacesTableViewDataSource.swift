//
//  PlacesTableViewDataSource.swift
//  Circle
//
//  Created by Kviatkovskii on 02/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher

final class PlacesTableViewDataSource: NSObject {
    var places: Places
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    
    init(_ tableView: UITableView, places: Places, kingfisherOptions: KingfisherOptionsInfo) {
        self.places = places
        self.kingfisherOptions = kingfisherOptions
        super.init()
        tableView.dataSource = self
    }
}

extension PlacesTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = places.items[indexPath.row]
        let rating = places.ratings[indexPath.row]
        let title = places.titles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.cellIndetifier,
                                                 for: indexPath) as? PlaceTableViewCell ?? PlaceTableViewCell()
        
        cell.rating = rating
        cell.title = title
        cell.imageCell.kf.indicatorType = .activity
        cell.imageCell.kf.setImage(with: place.coverPhoto?.url,
                                   placeholder: nil,
                                   options: self.kingfisherOptions,
                                   progressBlock: nil,
                                   completionHandler: nil)
        
        return cell
    }
}
