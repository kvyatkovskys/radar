//
//  Router.swift
//  Circle
//
//  Created by Kviatkovskii on 09/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher

final class Router {
    fileprivate lazy var optionKingfisher: KingfisherOptionsInfo = {
        return [KingfisherOptionsInfoItem.transition(.fade(0.2))]
    }()
    fileprivate let rootViewController: UINavigationController
    
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    func showMainTabController() -> UITabBarController {
        let placesViewController = PlacesViewController(PlacesViewDependecies(self, optionKingfisher, PlaceViewModel(PlaceService())))
        let locationImage = UIImage(named: "ic_my_location")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        placesViewController.navigationItem.title = "Around here"
        placesViewController.tabBarItem = UITabBarItem(title: "My location", image: locationImage, tag: 1)
        placesViewController.navigationController?.navigationBar.isTranslucent = true
        if #available(iOS 11.0, *) {
            placesViewController.navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 28)]
            placesViewController.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        }
        
        let settingsController = SettingsViewController(SettingsViewDependecies(self))
        let settingsImage = UIImage(named: "ic_settings")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        settingsController.navigationItem.title = "Settings of app"
        settingsController.tabBarItem = UITabBarItem(title: "Settings", image: settingsImage, tag: 2)
        
        let tabBar = UITabBarController()
        tabBar.viewControllers = [placesViewController, settingsController].map({ UINavigationController(rootViewController: $0) })
        return tabBar
    }
}
