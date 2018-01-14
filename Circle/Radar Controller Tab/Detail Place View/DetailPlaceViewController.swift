//
//  DetailPlaceViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 13/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher

let heightHeaderTable: CGFloat = 200.0

final class DetailPlaceViewController: UIViewController {
    typealias Dependecies = HasDetailPlaceModel & HasKingfisher
    
    fileprivate let place: PlaceModel
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    
    fileprivate lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: heightHeaderTable))
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var imageHeader: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.kf.indicatorType = .activity
        image.kf.setImage(with: place.coverPhoto?.url,
                                placeholder: nil,
                                options: self.kingfisherOptions,
                                progressBlock: nil,
                                completionHandler: nil)
        return image
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView(frame: CGRect.zero)
        return table
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        imageHeader.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    init(_ dependecies: Dependecies) {
        self.place = dependecies.place
        self.kingfisherOptions = dependecies.kingfisherOptions
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.addSubview(imageHeader)
        tableView.tableHeaderView = headerView
        view.addSubview(tableView)
        updateViewConstraints()
    }
}
