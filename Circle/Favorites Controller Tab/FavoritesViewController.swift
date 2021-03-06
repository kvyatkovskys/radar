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
import Swinject

fileprivate extension UIColor {
    static var alert: UIColor {
        return UIColor(withHex: 0xff3232, alpha: 1.0)
    }
}

final class FavoritesViewController: UIViewController {

    fileprivate var viewModel: FavoritesViewModel
    fileprivate var notificationToken: NotificationToken?
    fileprivate var notificationSettingsToken: NotificationToken?
    
    fileprivate lazy var tableView: KSTableView = {
        let table = KSTableView()
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    fileprivate lazy var leftBarButton: UIBarButtonItem = {
        let categoriesImage = UIImage(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: categoriesImage, style: .done, target: self, action: #selector(showAlert))
        button.tintColor = .alert
        return button
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    init(_ container: Container) {
        self.viewModel = container.resolve(FavoritesViewModel.self)!
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
            let settings = realm.objects(Settings.self)
            
            notificationToken = results.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial(let collection):
                    self.viewModel.dataSource = self.viewModel.updateValue(collection.map({ $0 }))
                    self.tableView.reloadData()
                case .update(let collection, let deletions, let insertions, let modifications):
                    self.viewModel.dataSource = self.viewModel.updateValue(collection.map({ $0 }))
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self.tableView.endUpdates()
                case .error(let error):
                    fatalError("\(error)")
                }
            }
            
            notificationSettingsToken = settings.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial(let collection), .update(let collection, _, _, _):
                    guard collection.first?.allwaysLocation ?? true else {
                        self.navigationItem.leftBarButtonItem = self.leftBarButton
                        return
                    }
                    self.navigationItem.leftBarButtonItem = nil
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
        notificationSettingsToken?.invalidate()
    }
    
    @objc func showAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("warning", comment: "Title for warning"),
                                                message: NSLocalizedString("recieveNotifyFromFavorites",
                                                                           comment: "Text when location not equal always"),
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Title for cancel"),
                                         style: .cancel,
                                         handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: NSLocalizedString("openSettings",
                                                                comment: "Title for button to open settings"), style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.cellIndetifier,
                                                 for: indexPath) as? PlaceTableViewCell ?? PlaceTableViewCell()

        cell.title = viewModel.dataSource[indexPath.row].name
        cell.rating = viewModel.dataSource[indexPath.row].rating
        cell.titleCategory = viewModel.dataSource[indexPath.row].categories?.first?.title
        cell.colorCategory = viewModel.dataSource[indexPath.row].categories?.first?.color
        cell.imageCell.kf.indicatorType = .activity
        cell.imageCell.kf.setImage(with: viewModel.dataSource[indexPath.row].picture,
                                   placeholder: nil,
                                   options: viewModel.optionsKingfisher,
                                   progressBlock: nil,
                                   completionHandler: { (_) in })
        return cell
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive,
                                          title: NSLocalizedString("remove", comment: "Title for remove")) { [unowned self] (_, indexPath) in
            self.viewModel.deleteFromFavorites(id: self.viewModel.dataSource[indexPath.row].id)
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightTableCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let favorite = viewModel.dataSource[indexPath.row]
        let place = PlaceModel(id: favorite.id,
                               name: favorite.name,
                               ratingStar: favorite.ratingStar,
                               ratingCount: favorite.ratingCount,
                               website: favorite.website,
                               categories: favorite.categories,
                               subCategories: favorite.subCategories,
                               coverPhoto: favorite.picture,
                               about: favorite.about,
                               fromFavorites: true)
        viewModel.openDetailPlace(place, viewModel)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
