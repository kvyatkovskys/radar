//
//  DetailPlaceViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 13/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher

let heightHeaderTable: CGFloat = 150.0

final class DetailPlaceViewController: UIViewController {
    typealias Dependecies = HasDetailPlaceViewModel & HasKingfisher
    
    fileprivate let viewModel: DetailPlaceViewModel
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    
    fileprivate lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: heightHeaderTable))
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var imageHeader: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 5.0
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.kf.indicatorType = .activity
        image.kf.setImage(with: viewModel.place.info.coverPhoto?.url,
                                placeholder: nil,
                                options: self.kingfisherOptions,
                                progressBlock: nil,
                                completionHandler: nil)
        return image
    }()
    
    fileprivate lazy var titlePlace: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17.0)
        label.attributedText = self.viewModel.place.title
        return label
    }()
    
    fileprivate lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.attributedText = self.viewModel.place.rating
        return label
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView(frame: CGRect.zero)
        return table
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        imageHeader.snp.makeConstraints { (make) in
            make.top.left.equalTo(headerView).offset(10.0)
            make.width.equalTo(100.0)
            make.height.equalTo(130.0)
        }
        
        titlePlace.snp.makeConstraints { (make) in
            make.top.equalTo(imageHeader)
            make.left.equalTo(imageHeader.snp.right).offset(10.0)
            make.right.equalTo(headerView).offset(-10.0)
            make.bottom.equalTo(ratingLabel.snp.top).offset(-10.0)
        }
        
        ratingLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(imageHeader)
            make.left.equalTo(titlePlace)
            make.height.equalTo(15.0)
        }
    }
    
    init(_ dependecies: Dependecies) {
        self.viewModel = dependecies.viewModel
        self.kingfisherOptions = dependecies.kingfisherOptions
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.addSubview(imageHeader)
        headerView.addSubview(titlePlace)
        headerView.addSubview(ratingLabel)
        tableView.tableHeaderView = headerView
        view.addSubview(tableView)
        updateViewConstraints()
        
        tableView.register(DetailDescriptionTableViewCell.self, forCellReuseIdentifier: DetailDescriptionTableViewCell.cellIdentifier)
        tableView.register(DeatilPhoneWebsiteTableViewCell.self, forCellReuseIdentifier: DeatilPhoneWebsiteTableViewCell.cellIdentifier)
    }
}

extension DetailPlaceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = viewModel.dataSource[indexPath.row]
        
        switch type {
        case .description(let text, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailDescriptionTableViewCell.cellIdentifier,
                                                     for: indexPath) as? DetailDescriptionTableViewCell ?? DetailDescriptionTableViewCell()
            
            cell.textDescription = text
            
            return cell
        case .phoneAndSite:
            let cell = tableView.dequeueReusableCell(withIdentifier: DeatilPhoneWebsiteTableViewCell.cellIdentifier,
                                                     for: indexPath) as? DeatilPhoneWebsiteTableViewCell ?? DeatilPhoneWebsiteTableViewCell()
            
            return cell
        }
    }
}

extension DetailPlaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = viewModel.dataSource[indexPath.row]
        
        switch type {
        case .description(_, let height):
            return height
        case .phoneAndSite:
            return 60.0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y > -23.0 else {
            navigationItem.title = ""
            return
        }
        
        navigationItem.title = viewModel.place.info.name
    }
}
