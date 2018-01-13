//
//  DetailPlaceViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 13/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class DetailPlaceViewController: UIViewController {
    typealias Dependecies = HasDetailPlaceModel
    
    fileprivate let place: PlaceModel
    
    init(_ dependecies: Dependecies) {
        self.place = dependecies.place
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
