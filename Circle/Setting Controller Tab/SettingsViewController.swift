//
//  SettingsViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 24/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {
    typealias Dependecies = HasRouter
    
    fileprivate let router: Router
    
    init(_ dependencies: Dependecies) {
        self.router = dependencies.router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
