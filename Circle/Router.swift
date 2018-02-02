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
        return UIColor(withHex: 0xf82462, alpha: 1.0)
    }
}

struct Router {
    fileprivate let optionKingfisher: KingfisherOptionsInfo = {
        return [KingfisherOptionsInfoItem.transition(.fade(0.2))]
    }()
    
    func showMainTabController() -> UITabBarController {
        //swiftlint:disable force_cast
        var placesViewController = UIViewController()
        var viewModel = PlaceViewModel(PlaceService())
        
        viewModel.openFilter = { delegate in
            let dependecies = FilterPlacesDependecies(FilterViewModel(), FilterDistanceViewModel(), FilterCategoriesViewModel(), delegate)
            self.openFilterPlaces(fromController: placesViewController as! PlacesViewController,
                                  toController: FilterPlacesViewController(dependecies))
        }
        
        viewModel.openMap = { places, location, sourceRect in
            let dependecies = MapDependecies(places, location)
            self.openMap(fromController: placesViewController as! PlacesViewController,
                         toController: MapViewController(dependecies),
                         sourceRect: sourceRect)
        }
        
        viewModel.openDetailPlace = { place, title, rating, favoritesViewModel in
            self.openDetailPlace(place, title, rating, favoritesViewModel, placesViewController)
        }
        
        placesViewController = PlacesViewController(PlacesViewDependecies(optionKingfisher, viewModel))
        let locationImage = UIImage(named: "ic_my_location")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        placesViewController.navigationItem.title = "Around here"
        placesViewController.tabBarItem = UITabBarItem(title: "My location", image: locationImage, tag: 1)
        placesViewController.navigationController?.navigationBar.isTranslucent = true
        
        // Search Controller
        let searchViewController = SearchViewController()
        let searchImage = UIImage(named: "ic_search")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        searchViewController.navigationItem.title = "Find a place"
        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: searchImage, tag: 2)
        searchViewController.navigationController?.navigationBar.isTranslucent = true
        
        // Favorites Controller
        var favoritesViewController = UIViewController()
        var favoritesViewModel = FavoritesViewModel()
        
        favoritesViewModel.openDetailPlace = { place, title, rating, viewModel in
            self.openDetailPlace(place, title, rating, viewModel, favoritesViewController)
        }
        favoritesViewController = FavoritesViewController(FavoritesDependencies(favoritesViewModel, optionKingfisher))
        let favoriteImage = UIImage(named: "ic_favorite")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        favoritesViewController.navigationItem.title = "Favorites"
        favoritesViewController.tabBarItem = UITabBarItem(title: "Favorites", image: favoriteImage, tag: 3)
        favoritesViewController.navigationController?.navigationBar.isTranslucent = true
        
        // Setting Controller
        let settingsController = SettingsViewController(SettingsViewDependecies(SettingsViewModel()))
        let settingsImage = UIImage(named: "ic_settings")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        settingsController.navigationItem.title = "Application settings"
        settingsController.tabBarItem = UITabBarItem(title: "Settings", image: settingsImage, tag: 4)
        settingsController.navigationController?.navigationBar.isTranslucent = true
        
        // Tab View Controller
        let tabController = UITabBarController()
        tabController.tabBar.tintColor = UIColor.tabColor
        tabController.viewControllers = [placesViewController,
                                         searchViewController,
                                         favoritesViewController,
                                         settingsController].map({ UINavigationController(rootViewController: $0) })
        return tabController
    }
    
    /// open detail controller about place
    fileprivate func openDetailPlace(_ place: PlaceModel,
                                     _ title: NSMutableAttributedString?,
                                     _ rating: NSMutableAttributedString?,
                                     _ favoritesViewModel: FavoritesViewModel,
                                     _ fromController: UIViewController) {
        let dependecies = DetailPlaceDependecies(DetailPlaceViewModel(place, title, rating, FavoritesService()),
                                                 favoritesViewModel,
                                                 optionKingfisher,
                                                 OpenGraphService())
        let detailPlaceController = DetailPlaceViewController(dependecies)
        detailPlaceController.hidesBottomBarWhenPushed = true
        fromController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        fromController.navigationController?.pushViewController(detailPlaceController, animated: true)
    }
    
    /// open filter controller
    fileprivate func openFilterPlaces(fromController: PlacesViewController, toController: UIViewController) {
        let navigation = UINavigationController(rootViewController: toController)
        navigation.modalPresentationStyle = UIModalPresentationStyle.popover
        navigation.isNavigationBarHidden = true
        let popover = navigation.popoverPresentationController
        popover?.delegate = fromController
        popover?.barButtonItem = fromController.rightBarButton
        popover?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        fromController.present(navigation, animated: true, completion: nil)
    }
    
    /// open map controller
    fileprivate func openMap(fromController: PlacesViewController, toController: UIViewController, sourceRect: CGRect) {
        let navigation = UINavigationController(rootViewController: toController)
        navigation.modalPresentationStyle = UIModalPresentationStyle.popover
        navigation.isNavigationBarHidden = true
        
        let popover = navigation.popoverPresentationController
        popover?.delegate = fromController
        popover?.sourceRect = sourceRect
        popover?.sourceView = fromController.view
        
        let width = fromController.view.frame.size.width
        let height = fromController.view.frame.size.height - 200.0
        toController.preferredContentSize = CGSize(width: width, height: height)
    
        fromController.present(navigation, animated: true, completion: nil)
    }
}
