//
//  ListButtonsCollectionDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 20/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListButtonsCollectionDelegate: NSObject {
    fileprivate let buttons: [Contact]
    
    init(collectionView: UICollectionView, _ buttons: [Contact]) {
        self.buttons = buttons
        super.init()
        collectionView.delegate = self
    }
}

extension ListButtonsCollectionDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let contact = buttons[indexPath.row]
        switch contact.type {
        case .phone:
            if let url = URL(string: "tel://\(contact.value ?? 0)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .website, .facebook:
            if let url = URL(string: "\(contact.value ?? "")"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
