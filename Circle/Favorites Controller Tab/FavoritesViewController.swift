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
        super.init(nibName: nil, bundle: nil)
        
        do {
            let realm = try Realm()
            let results = realm.objects(Favorites.self)
            
            notificationToken = results.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    self.tableView.reloadData()
                case .update(let collection, _, _, _):
                    self.viewModel.favoritePlaces = self.viewModel.updateValue(collection.sorted(byKeyPath: "date", ascending: false).map({ $0 }))
                    self.tableView.reloadData()
                case .error(let error):
                    fatalError("\(error)")
                }
            }
        } catch {
            print(error)
        }
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
    
    deinit {
        notificationToken?.invalidate()
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favoritePlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.cellIndetifier,
                                                 for: indexPath) as? PlaceTableViewCell ?? PlaceTableViewCell()
        
        cell.title = viewModel.favoritePlaces[indexPath.row].title
        cell.rating = viewModel.favoritePlaces[indexPath.row].rating
        cell.titleCategory = viewModel.favoritePlaces[indexPath.row].categories?.first?.title
        cell.colorCategory = viewModel.favoritePlaces[indexPath.row].categories?.first?.color
        cell.imageCell.kf.indicatorType = .activity
        cell.imageCell.kf.setImage(with: viewModel.favoritePlaces[indexPath.row].picture,
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
            self.viewModel.deleteFromFavorites(id: self.viewModel.favoritePlaces[indexPath.row].id)
            self.viewModel.favoritePlaces.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }

        return [delete]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        let place = PlaceModel(id: viewModel.favoritePlaces[indexPath.row].id,
                               name: viewModel.favoritePlaces[indexPath.row].name,
                               categories: viewModel.favoritePlaces[indexPath.row].categories,
                               subCategories: viewModel.favoritePlaces[indexPath.row].subCategories,
                               coverPhoto: viewModel.favoritePlaces[indexPath.row].picture,
                               fromFavorites: true)
        let title = viewModel.favoritePlaces[indexPath.row].title
        let rating = viewModel.favoritePlaces[indexPath.row].rating
        viewModel.openDetailPlace(place, title, rating, viewModel)
    }
}
