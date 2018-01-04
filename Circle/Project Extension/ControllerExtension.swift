//
//  ControllerExtension.swift
//  Circle
//
//  Created by Kviatkovskii on 03/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

extension PlacesViewController: UIPopoverPresentationControllerDelegate {
    // MARK: UINavigationControllerDelegate
    public func adaptivePresentationStyle(for controller: UIPresentationController,
                                          traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
