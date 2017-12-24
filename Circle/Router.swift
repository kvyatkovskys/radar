//
//  Router.swift
//  Circle
//
//  Created by Kviatkovskii on 09/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit

final class Router {
    fileprivate let rootViewController: UINavigationController
    
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    func showMainTabController() -> UITabBarController {
        let mainViewController = MainViewController(MainViewDependecies(self))
        let locationImage = UIImage(named: "ic_my_location")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        mainViewController.navigationItem.title = "Near you"
        mainViewController.tabBarItem = UITabBarItem(title: "My location", image: locationImage, tag: 1)
        mainViewController.navigationController?.navigationBar.isTranslucent = true
        
        let settingsController = SettingsViewController(SettingsViewDependecies(self))
        let settingsImage = UIImage(named: "ic_settings")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        settingsController.navigationItem.title = "Settings of app"
        settingsController.tabBarItem = UITabBarItem(title: "Settings", image: settingsImage, tag: 2)
        
        let tabBar = UITabBarController()
        tabBar.viewControllers = [mainViewController, settingsController].map({ UINavigationController(rootViewController: $0) })
        return tabBar
    }
}
