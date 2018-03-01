//
//  PopoverLabelViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 28/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit

final class PopoverLabelViewController: UIViewController {

    fileprivate let fullTitle: String
    
    fileprivate let titlePlace: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        titlePlace.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview().inset(10.0)
        }
    }
    
    init(title: String) {
        self.fullTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        titlePlace.text = fullTitle
        view.addSubview(titlePlace)
        updateViewConstraints()
    }
}
