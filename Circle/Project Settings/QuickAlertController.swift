//
//  QuickAlertController.swift
//  Circle
//
//  Created by Kviatkovskii on 24/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit

struct TitleButtonAlert {
    static let buttonOK = NSLocalizedString("done", comment: "Title for done button")
    static let buttonCancel = NSLocalizedString("cancel", comment: "Title for cancel button")
}

extension UIViewController {
    func showAlertLight(title: String, message: String, buttonTitle: String = TitleButtonAlert.buttonOK) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        let button = UIAlertAction(title: buttonTitle,
                                   style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(button)
        
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
}
