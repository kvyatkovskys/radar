//
//  Router.swift
//  Circle
//
//  Created by Kviatkovskii on 09/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher

fileprivate extension UIColor {
    static var tabColor: UIColor {
        return UIColor(withHex: 0x2c3e50, alpha: 1.0)
    }
}

final class Router {
    fileprivate lazy var optionKingfisher: KingfisherOptionsInfo = {
        return [KingfisherOptionsInfoItem.transition(.fade(0.2))]
    }()
    fileprivate let rootViewController: UINavigationController
    
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    func showMainTabController() -> UITabBarController {
        var placesViewController = UIViewController()
        var viewModel = PlaceViewModel(PlaceService())
        
        viewModel.openFilter = { [unowned self] delegate in
            let dependecies = FilterPlacesDependecies(FilterViewModel(), FilterDistanceViewModel(), delegate)
            self.openFilterPlaces(fromController: placesViewController as! PlacesViewController,
                                  toController: FilterPlacesViewController(dependecies))
        }
        viewModel.openCategories = {
            
        }
        
        placesViewController = PlacesViewController(PlacesViewDependecies(optionKingfisher, viewModel))
        let locationImage = UIImage(named: "ic_my_location")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        placesViewController.navigationItem.title = "Around here"
        placesViewController.tabBarItem = UITabBarItem(title: "My location", image: locationImage, tag: 1)
        placesViewController.navigationController?.navigationBar.isTranslucent = true
        
        if #available(iOS 11.0, *) {
            placesViewController.navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 28)]
            placesViewController.navigationController?.navigationItem.largeTitleDisplayMode = .always
        }
        
        let settingsController = SettingsViewController(SettingsViewDependecies(self))
        let settingsImage = UIImage(named: "ic_settings")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        settingsController.navigationItem.title = "Settings of app"
        settingsController.tabBarItem = UITabBarItem(title: "Settings", image: settingsImage, tag: 2)
        
        let tabController = UITabBarController()
        tabController.tabBar.tintColor = UIColor.tabColor
        tabController.viewControllers = [placesViewController, settingsController].map({ UINavigationController(rootViewController: $0) })
        return tabController
    }
    
    /// open filter controller
    func openFilterPlaces(fromController: PlacesViewController, toController: UIViewController) {
        let navigation = UINavigationController(rootViewController: toController)
        navigation.modalPresentationStyle = UIModalPresentationStyle.popover
        navigation.isNavigationBarHidden = true
        let popover = navigation.popoverPresentationController
        toController.preferredContentSize = CGSize(width: 250.0, height: 200.0)
        popover?.delegate = fromController
        popover?.barButtonItem = fromController.rightBarButton
        popover?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        fromController.present(navigation, animated: true, completion: nil)
    }
}
