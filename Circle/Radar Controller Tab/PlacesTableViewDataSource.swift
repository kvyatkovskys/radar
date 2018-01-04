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
    var placesSections: PlacesSections
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    
    init(_ tableView: UITableView, placesSections: PlacesSections?, kingfisherOptions: KingfisherOptionsInfo) {
        self.placesSections = placesSections ?? PlacesSections([], [])
        self.kingfisherOptions = kingfisherOptions
        super.init()
        tableView.dataSource = self
    }
}

extension PlacesTableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return placesSections.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return placesSections.sections[section].reduce(" ", { acc, item in acc + item.title })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesSections.places[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = placesSections.places[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.cellIndetifier,
                                                 for: indexPath) as? PlaceTableViewCell ?? PlaceTableViewCell()
        
        cell.title = place.name
        cell.categories = place.categories
        cell.imageCell.kf.indicatorType = .activity
        cell.about = place.about
        cell.imageCell.kf.setImage(with: place.coverPhoto?.url,
                                   placeholder: nil,
                                   options: self.kingfisherOptions,
                                   progressBlock: nil,
                                   completionHandler: nil)
        
        return cell
    }
}
