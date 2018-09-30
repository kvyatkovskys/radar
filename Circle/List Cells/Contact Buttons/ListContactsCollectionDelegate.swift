//
//  ListContactsCollectionDelegate.swift
//  Circle
//
//  Created by Kviatkovskii on 20/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class ListContactsCollectionDelegate: NSObject {
    fileprivate let buttons: [Contact]
    
    init(collectionView: UICollectionView, _ buttons: [Contact]) {
        self.buttons = buttons
        super.init()
        collectionView.delegate = self
    }
}

extension ListContactsCollectionDelegate: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contact = buttons[indexPath.row]
        return CGSize(width: contact.type.width, height: 40.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let contact = buttons[indexPath.row]
        switch contact.type {
        case .phone:
            if let url = URL(string: "tel://\(contact.value ?? "")"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                let localized = NSLocalizedString("telephone", comment: "Title for teh alert show phone")
                UIApplication.shared.keyWindow?.rootViewController?.showAlertLight(title: localized, message: "\(contact.value ?? "")")
            }
        case .website:
            if let url = URL(string: "\(contact.value ?? "")"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        case .facebook:
            let urlApp = URL(string: "fb://page/?id=\(contact.value ?? "")")!
            let urlWeb = URL(string: "https://facebook.com/\(contact.value ?? "")")!
            guard UIApplication.shared.canOpenURL(urlApp) else {
                UIApplication.shared.open(urlWeb, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                return
            }
            UIApplication.shared.open(urlApp, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
