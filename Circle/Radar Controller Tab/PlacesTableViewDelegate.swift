//
//  PlacesTableViewDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 02/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class PlacesTableViewDelegate: NSObject {
    var placesSections: PlacesSections
    fileprivate let viewModel: PlaceViewModel
    
    init(_ tableView: UITableView, placesSections: PlacesSections, viewModel: PlaceViewModel) {
        self.placesSections = placesSections
        self.viewModel = viewModel
        super.init()
        tableView.delegate = self
    }
}

extension PlacesTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: PlaceHeaderTableViewCell.cellIdentifier) as? PlaceHeaderTableViewCell ?? PlaceHeaderTableViewCell()
        
        header.color = placesSections.sections[section].first?.color
        header.title = placesSections.sections[section].first?.title
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let place = placesSections.places[indexPath.section][indexPath.row]
        viewModel.openDetailPlace(place)
    }
}
