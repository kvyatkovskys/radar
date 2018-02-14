//
//  FavoritesViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 27/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift

final class FavoritesViewController: UIViewController {
    typealias Dependecies = HasFavoritesViewModel & HasKingfisher

    fileprivate var viewModel: FavoritesViewModel
    fileprivate var dataSource: [FavoritesModel]
    fileprivate let optionsKingfisher: KingfisherOptionsInfo
    fileprivate var notificationToken: NotificationToken?
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.delegate = self
        table.dataSource = self
        table.separatorColor = .clear
        return table
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(64.0)
            make.bottom.left.right.equalToSuperview()
        }
    }
    
    init(_ dependecies: Dependecies) {
        self.viewModel = dependecies.favoritesViewModel
        self.optionsKingfisher = dependecies.kingfisherOptions
        self.dataSource = dependecies.favoritesViewModel.favoritePlaces
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
        
        do {
            let realm = try Realm()
            let results = realm.objects(Favorites.self).sorted(byKeyPath: "date", ascending: false)
            
            notificationToken = results.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    break
                case .update(let collection, let deletions, let insertions, _):
                    self.dataSource = self.viewModel.updateValue(collection.map({ $0 }))
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self.tableView.endUpdates()
                case .error(let error):
                    fatalError("\(error)")
                }
            }
        } catch {
            print(error)
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.cellIndetifier,
                                                 for: indexPath) as? PlaceTableViewCell ?? PlaceTableViewCell()

        cell.title = dataSource[indexPath.row].title
        cell.rating = dataSource[indexPath.row].rating
        cell.titleCategory = dataSource[indexPath.row].categories?.first?.title
        cell.colorCategory = dataSource[indexPath.row].categories?.first?.color
        cell.imageCell.kf.indicatorType = .activity
        cell.imageCell.kf.setImage(with: dataSource[indexPath.row].picture,
                                   placeholder: nil,
                                   options: optionsKingfisher,
                                   progressBlock: nil,
                                   completionHandler: nil)
        return cell
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Remove") { [unowned self] (_, indexPath) in
            self.viewModel.deleteFromFavorites(id: self.dataSource[indexPath.row].id)
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let favorite = dataSource[indexPath.row]
        let place = PlaceModel(id: favorite.id,
                               name: favorite.name,
                               ratingStar: favorite.ratingStar,
                               ratingCount: favorite.ratingCount,
                               categories: favorite.categories,
                               subCategories: favorite.subCategories,
                               coverPhoto: favorite.picture,
                               about: favorite.about,
                               fromFavorites: true)
        let title = favorite.title
        let rating = favorite.rating
        viewModel.openDetailPlace(place, title, rating, viewModel)
    }
}
