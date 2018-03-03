//
//  PhtotPreviewerViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 03/03/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import Lightbox

final class PhotoPreviewerViewController: UIViewController {

    typealias Dependecies = HasSourceImages
    
    fileprivate let images: [URL]
    fileprivate let startIndex: Int
    
    init(_ dependencies: Dependecies) {
        self.images = dependencies.images
        self.startIndex = dependencies.startIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let lightbox = LightboxController(images: images.map({ LightboxImage(imageURL: $0) }), startIndex: startIndex)
        lightbox.dismissalDelegate = self
        lightbox.dynamicBackground = true
        present(lightbox, animated: true, completion: nil)
    }
}

extension PhotoPreviewerViewController: LightboxControllerDismissalDelegate {
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        dismiss(animated: false, completion: nil)
    }
}
