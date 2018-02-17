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

final class RoundedVisualEffectView: UIVisualEffectView {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMaskLayer()
    }
    
    func updateMaskLayer() {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: [.bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: 5.0, height: 5.0))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

let heightTableCell: CGFloat = 250.0

final class KSTableView: UITableView {
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.backgroundColor = UIColor.lightGrayTable
        self.separatorColor = .clear
        self.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
