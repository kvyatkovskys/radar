//
//  PlacesTableViewDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 02/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class PlacesTableViewDelegate: NSObject {
    var places: Places
    fileprivate let viewModel: PlaceViewModel
    
    init(_ tableView: UITableView, places: Places, viewModel: PlaceViewModel) {
        self.places = places
        self.viewModel = viewModel
        super.init()
        tableView.delegate = self
    }
}

extension PlacesTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let place = places.items[indexPath.row]
        let title = places.titles[indexPath.row]
        let rating = places.ratings[indexPath.row]
        viewModel.openDetailPlace(Place(info: place, title: title, rating: rating))
    }
}
