//
//  DetailPlaceViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 13/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import SnapKit
import Swinject

final class DetailPlaceViewController: UIViewController, UIGestureRecognizerDelegate {
    fileprivate var notificationTokenFavorites: NotificationToken?
    fileprivate var viewModel: DetailPlaceViewModel
    fileprivate let favoritesViewModel: FavoritesViewModel
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var favoriteNotify: FavoritesNotify {
        return favoritesViewModel.checkAddAndNotify(viewModel.place)
    }
    
    fileprivate lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: viewModel.heightHeader))
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var imageHeader: UIImageView = {
        var image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .shadowGray
        
        image.kf.indicatorType = .activity
        image.kf.setImage(with: viewModel.place.coverPhoto,
                          placeholder: nil,
                          options: viewModel.kingfisherOptions,
                          progressBlock: nil,
                          completionHandler: { (_) in })
        return image
    }()
    
    fileprivate lazy var picture: UIImageView = {
        var image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.backgroundColor = .shadowGray
        image.layer.shadowColor = UIColor.black.cgColor
        image.layer.shadowRadius = 4.0
        image.layer.shadowOpacity = 0.4
        image.layer.shadowOffset = CGSize.zero
        
        image.kf.indicatorType = .activity
        viewModel.getPictureProfile().asObservable()
            .subscribe(onNext: { [unowned self] (url) in
                image.kf.setImage(with: url,
                                  placeholder: nil,
                                  options: self.viewModel.kingfisherOptions,
                                  progressBlock: nil,
                                  completionHandler: { (_) in })
            }, onError: { (error) in
                print(error)
            }).disposed(by: disposeBag)
        
        return image
    }()
    
    lazy var titlePlace: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = self.viewModel.title
        label.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openFullTitle))
        label.addGestureRecognizer(tap)
        return label
    }()
    
    fileprivate lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = self.viewModel.rating
        return label
    }()
    
    fileprivate lazy var listSubCategoriesView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        let color: UIColor?
        if (self.viewModel.place.categories ?? []).isEmpty {
            color = UIColor.mainColor
        } else {
            color = self.viewModel.place.categories?.first?.color
        }
        
        let listCategories = ListCategoriesViewController(ListSubCategoriesViewModel(self.viewModel.place.subCategories ?? [], color: color))
        
        var frame = listCategories.view.frame
        frame.size.height = view.frame.height
        frame.size.width = view.frame.width
        listCategories.view.frame = frame
        
        addChild(listCategories)
        view.addSubview(listCategories.view)
        listCategories.didMove(toParent: listCategories)
        return view
    }()
    
    fileprivate lazy var favoriteButton: UIBarButtonItem = {
        let image: UIImage
        if favoriteNotify.addFavorites {
            image = UIImage(named: "ic_favorite")!.withRenderingMode(.alwaysTemplate)
        } else {
            image = UIImage(named: "ic_favorite_border")!.withRenderingMode(.alwaysTemplate)
        }
        let button = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(addToFavorites))
        return button
    }()
    
    fileprivate lazy var shareButton: UIBarButtonItem = {
        let image = UIImage(named: "ic_share")?.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(sharePlace))
        return button
    }()
    
    fileprivate let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.separatorColor = .clear
        return table
    }()
    
    fileprivate lazy var indicatorView: ActivityIndicatorView = {
        return ActivityIndicatorView(container: self.view)
    }()
    
    fileprivate func rightBarButton() -> UIBarButtonItem {
        let notifyImage: UIImage?
        
        if let allow = favoriteNotify.allowNotify, allow == true {
            notifyImage = UIImage(named: "ic_notifications_active")
        } else {
            notifyImage = UIImage(named: "ic_notifications_off")
        }

        let button = UIBarButtonItem(image: notifyImage, style: .plain, target: self, action: #selector(changeNotify))
        return button
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }
        
        imageHeader.snp.remakeConstraints { (make) in
            make.top.left.equalTo(tableView)
            make.width.equalTo(ScreenSize.SCREEN_WIDTH)
            make.height.equalTo(160.0)
        }
        
        lineView.snp.remakeConstraints { (make) in
            make.top.equalTo(imageHeader.snp.bottom)
            make.left.equalTo(tableView)
            make.height.equalTo(0.5)
            make.width.equalTo(imageHeader)
        }
        
        picture.snp.makeConstraints { (make) in
            make.top.equalTo(imageHeader.snp.bottom).offset(-15.0)
            make.left.equalTo(view).offset(10.0)
            make.size.equalTo(CGSize(width: 100.0, height: 100.0))
        }
        
        titlePlace.snp.remakeConstraints { (make) in
            make.top.equalTo(imageHeader.snp.bottom).offset(10.0)
            make.left.equalTo(picture.snp.right).offset(10.0)
            make.right.equalTo(view).offset(-10.0)
            make.bottom.equalTo(ratingLabel)
        }

        ratingLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(picture.snp.bottom).offset(10.0)
            make.left.right.equalTo(picture)
            make.height.equalTo(20.0)
        }

        listSubCategoriesView.snp.remakeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.right.equalTo(titlePlace)
            make.left.equalTo(ratingLabel)
            make.top.equalTo(titlePlace.snp.bottom).offset(10.0)
        }
    }
    
    init(_ container: Container) {
        self.viewModel = container.resolve(DetailPlaceViewModel.self)!
        self.favoritesViewModel = container.resolve(FavoritesViewModel.self)!
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleNavBar()
        
        if favoriteNotify.addFavorites {
            navigationItem.rightBarButtonItems = [shareButton, favoriteButton, rightBarButton()]
        } else {
            navigationItem.rightBarButtonItems = [shareButton, favoriteButton]
        }
        
        headerView.addSubview(imageHeader)
        headerView.addSubview(lineView)
        headerView.addSubview(picture)
        headerView.addSubview(titlePlace)
        headerView.addSubview(ratingLabel)
        headerView.addSubview(listSubCategoriesView)
        tableView.tableHeaderView = headerView
        view.addSubview(tableView)
        updateViewConstraints()
        
        do {
            let realm = try Realm()
            let favorites = realm.objects(Favorites.self).filter("id = \(self.viewModel.place.id)")
            notificationTokenFavorites = favorites.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .update(let favorites, _, _, _):
                    if let favorite = favorites.first, let url = URL(string: favorite.picture ?? ""), self.viewModel.place.fromFavorites {
                        self.viewModel.place.website = favorite.website
                        self.imageHeader.kf.indicatorType = .activity
                        self.imageHeader.kf.setImage(with: url,
                                                     placeholder: nil,
                                                     options: self.viewModel.kingfisherOptions,
                                                     progressBlock: nil,
                                                     completionHandler: { (_) in })
                    }
                    
                    guard self.favoritesViewModel.checkAddAndNotify(self.viewModel.place).addFavorites else {
                        self.favoriteButton.image = UIImage(named: "ic_favorite_border")?.withRenderingMode(.alwaysTemplate)
                        self.navigationItem.rightBarButtonItems = [self.shareButton, self.favoriteButton]
                        return
                    }
                    
                    self.favoriteButton.image = UIImage(named: "ic_favorite")?.withRenderingMode(.alwaysTemplate)
                    self.navigationItem.rightBarButtonItems = [self.shareButton, self.favoriteButton, self.rightBarButton()]
                case .error(let error):
                    fatalError("\(error)")
                case .initial:
                    break
                }
            }
        } catch {
            print(error)
        }
        
        tableView.registerCellClasses(cellType: TypeDetailCell.self) { (item) -> UITableViewCell.Type in
            switch item {
            case .description:
                return DetailDescriptionTableViewCell.self
            case .contact:
                return DeatilContactsTableViewCell.self
            case .address:
                return DetailAddressTableViewCell.self
            case .workDays:
                return DetailWorkDaysTableViewCell.self
            case .parking, .payment:
                return DetailItemsTableViewCell.self
            case .restaurantService, .restaurantSpeciality:
                return DetailRestaurantTableViewCell.self
            case .images:
                return DetailImagesTableViewCell.self
            }
        }
        
        if viewModel.place.fromFavorites {
            indicatorView.showIndicator()
        }
        
        Observable.combineLatest(viewModel.loadPhotos(), viewModel.getInfoAboutPlace(id: viewModel.place.id))
            .flatMapLatest { [unowned self] (sourceImages, sourceForFavorite) -> Observable<[DetailSectionObjects]> in
                var dataSource = self.viewModel.dataSource
                dataSource.insert(sourceImages, at: 0)
                
                guard self.viewModel.place.fromFavorites else {
                    return Observable.just(dataSource)
                }
                
                dataSource = sourceForFavorite
                dataSource.insert(sourceImages, at: 0)
                self.indicatorView.hideIndicator()
                return Observable.just(dataSource)
            }
            .asObservable()
            .subscribe(onNext: { [unowned self] (dataSource) in
                self.viewModel.dataSource = dataSource
                self.tableView.reloadData()
            }, onError: { (error) in
                print(error)
                self.indicatorView.hideIndicator()
            }).disposed(by: disposeBag)
    }
    
    deinit {
        notificationTokenFavorites?.invalidate()
    }
    
    @objc func openFullTitle() {
        let router = Router()
        let popoverLabelController = PopoverLabelViewController(title: viewModel.place.about ?? "")
        if let height = viewModel.title?.string.height(font: .systemFont(ofSize: 16.0), width: titlePlace.bounds.width), height > titlePlace.bounds.height {
            router.openPopoverLabel(fromController: self, toController: popoverLabelController, height: height)
        }
    }
    
    @objc func changeNotify() {
        let allow = favoritesViewModel.allowNotify(place: viewModel.place)
    
        guard allow else {
            navigationItem.rightBarButtonItems?.last?.image = UIImage(named: "ic_notifications_off")
            return
        }
        navigationItem.rightBarButtonItems?.last?.image = UIImage(named: "ic_notifications_active")
    }
    
    @objc func addToFavorites() {
        guard favoriteNotify.addFavorites else {
            favoritesViewModel.addToFavorite(place: viewModel.place)
            return
        }
        favoritesViewModel.deleteFromFavorites(id: viewModel.place.id)
    }
    
    @objc func sharePlace() {
        UIImpactFeedbackGenerator().impactOccurred()
        if let image = imageHeader.image, let name = viewModel.place.name {
            var text = name
            
            if let about = viewModel.place.about {
                text += "\n\n" + about
            }

            if let url = viewModel.place.website {
                text += "\n\n" + url
            }

            let shareController = UIActivityViewController(activityItems: [image, text], applicationActivities: nil)
            present(shareController, animated: true, completion: nil)
        }
    }
    
    func setTitleNavBar() {
        navigationItem.title = viewModel.place.categories?.reduce("", { (acc, item) -> String in
            return "\(acc) " + "\(item.title)"
        })
    }
}

extension DetailPlaceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource[section].sectionObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = viewModel.dataSource[indexPath.section].sectionObjects[indexPath.row]
        
        switch type {
        case .images(let images, let previews, let nextImages, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: type.rawValue,
                                                     for: indexPath) as? DetailImagesTableViewCell ?? DetailImagesTableViewCell()
            
            cell.controller = self
            cell.viewModel = viewModel
            cell.pageImages = PageImages(images, previews, nextImages, viewModel.kingfisherOptions)
            return cell
        case .description(let text, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: type.rawValue,
                                                     for: indexPath) as? DetailDescriptionTableViewCell ?? DetailDescriptionTableViewCell()
            
            cell.textDescription = text
            return cell
        case .contact(let contacts, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: type.rawValue,
                                                     for: indexPath) as? DeatilContactsTableViewCell ?? DeatilContactsTableViewCell()
            
            cell.contacts = contacts
            return cell
        case .address(let address, let location, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: type.rawValue,
                                                     for: indexPath) as? DetailAddressTableViewCell ?? DetailAddressTableViewCell()
            
            cell.title = viewModel.place.name
            cell.address = address
            cell.location = location
            return cell
        case .workDays(let workDays, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: type.rawValue,
                                                     for: indexPath) as? DetailWorkDaysTableViewCell ?? DetailWorkDaysTableViewCell()
            
            cell.workDays = workDays
            return cell
        case .payment(let payments, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: type.rawValue,
                                                     for: indexPath) as? DetailItemsTableViewCell ?? DetailItemsTableViewCell()
            
            cell.payments = payments
            return cell
        case .parking(let parkings, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: type.rawValue,
                                                     for: indexPath) as? DetailItemsTableViewCell ?? DetailItemsTableViewCell()
            
            cell.parkings = parkings
            return cell
        case .restaurantService(let services, _, let color):
            let cell = tableView.dequeueReusableCell(withIdentifier: type.rawValue,
                                                     for: indexPath) as? DetailRestaurantTableViewCell ?? DetailRestaurantTableViewCell()
            
            cell.restaurantService = RestaurantService(services, color)
            return cell
        case .restaurantSpeciality(let specialties, _, let color):
            let cell = tableView.dequeueReusableCell(withIdentifier: type.rawValue,
                                                     for: indexPath) as? DetailRestaurantTableViewCell ?? DetailRestaurantTableViewCell()
            
            cell.restaurantSpeciatity = RestaurantSpeciality(specialties, color)
            return cell
        }
    }
}

extension DetailPlaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: DetailSectionTableViewCell.cellIdentifier) as? DetailSectionTableViewCell ?? DetailSectionTableViewCell()
        header.title = viewModel.dataSource[section].sectionName
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = viewModel.dataSource[indexPath.section].sectionObjects[indexPath.row]
        
        switch type {
        case .description(_, let height),
             .contact(_, let height),
             .address(_, _, let height),
             .workDays(_, let height),
             .payment(_, let height),
             .parking(_, let height),
             .restaurantService(_, let height, _),
             .restaurantSpeciality(_, let height, _),
             .images(_, _, _, let height): return height
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y > 200.0 else {
            setTitleNavBar()
            return
        }
        navigationItem.title = viewModel.place.name
    }
}
