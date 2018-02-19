//
//  View+Extension.swift
//  Circle
//
//  Created by Kviatkovskii on 11/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import Foundation

extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
