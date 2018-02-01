//
//  PlacesTableViewDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 02/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift

final class PlacesTableViewDelegate: NSObject {
    var places: [Places]
    fileprivate let viewModel: PlaceViewModel
    let nextUrl = PublishSubject<URL>()
    
    init(_ tableView: UITableView, places: [Places] = [], viewModel: PlaceViewModel) {
        self.places = places
        self.viewModel = viewModel
        super.init()
        tableView.delegate = self
    }
}

extension PlacesTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 4
        if let url = places[indexPath.section].next, indexPath.row == lastRowIndex, indexPath.section == lastSectionIndex {
            nextUrl.onNext(url)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let place = places[indexPath.section].items[indexPath.row]
        let title = places[indexPath.section].titles[indexPath.row]
        let rating = places[indexPath.section].ratings[indexPath.row]
        viewModel.openDetailPlace(Place(info: place, title: title, rating: rating), FavoritesViewModel(place))
    }
}
