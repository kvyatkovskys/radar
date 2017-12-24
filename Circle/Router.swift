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
    
    // контроллер на главный экран
    func showMainController() {
        let mainViewController = MainViewController(MainViewDependecies(self))
        rootViewController.setViewControllers([mainViewController], animated: true)
        rootViewController.isNavigationBarHidden = true
        rootViewController.navigationBar.isTranslucent = true
    }
}
