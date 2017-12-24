//
//  QuickAlertController.swift
//  Circle
//
//  Created by Kviatkovskii on 24/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit

struct TitleButtonAlert {
    static let buttonOK = "Done"
    static let buttonCancel = "Cancel"
}

extension UIViewController {
    func showAlertLight(title: String, message: String, buttonTitle: String = TitleButtonAlert.buttonOK) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        let button = UIAlertAction(title: buttonTitle,
                                   style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(button)
        
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }
}
