//
//  ResultSearchViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 02/02/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

final class ResultSearchViewController: UIViewController {

    typealias Dependecies = HasKingfisher
    typealias Result = (place: PlaceModel, title: NSMutableAttributedString?, rating: NSMutableAttributedString?)
    
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    fileprivate var dataSource: [Places] = [Places([], [], [], nil)]
    let selectResult = PublishSubject<Result>()
    
    fileprivate lazy var tableView: KSTableView = {
        let table = KSTableView()
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(64.0)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    init(_ dependecies: Dependecies) {
        self.kingfisherOptions = dependecies.kingfisherOptions
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        updateViewConstraints()
        
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.cellIndetifier)
    }
    
    func updateTable(places: Places) {
        dataSource = [places]
        tableView.reloadData()
    }
}

extension ResultSearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = dataSource[indexPath.section].items[indexPath.row]
        let rating = dataSource[indexPath.section].ratings[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.cellIndetifier,
                                                 for: indexPath) as? PlaceTableViewCell ?? PlaceTableViewCell()
        
        cell.rating = rating
        cell.title = place.name
        cell.titleCategory = place.categories?.first?.title
        cell.colorCategory = place.categories?.first?.color
        cell.imageCell.kf.indicatorType = .activity
        cell.imageCell.kf.setImage(with: place.coverPhoto,
                                   placeholder: nil,
                                   options: self.kingfisherOptions,
                                   progressBlock: nil,
                                   completionHandler: nil)
        
        return cell
    }
}

extension ResultSearchViewController: UITableViewDelegate {    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightTableCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let place = dataSource[indexPath.section].items[indexPath.row]
        let title = dataSource[indexPath.section].titles[indexPath.row]
        let rating = dataSource[indexPath.section].ratings[indexPath.row]
        selectResult.onNext(Result(place, title, rating))
    }
}
