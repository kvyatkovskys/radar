//
//  DetailPlaceViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 13/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import RealmSwift

let heightHeaderTable: CGFloat = 220.0

fileprivate extension UIColor {
    static var shadowGray: UIColor {
        return UIColor(withHex: 0xecf0f1, alpha: 0.7)
    }

    static var mainColor: UIColor {
        return UIColor(withHex: 0xf82462, alpha: 1.0)
    }
    
    static var notifyEnabled: UIColor {
        return UIColor(withHex: 0xF62232, alpha: 1.0)
    }
}

final class DetailPlaceViewController: UIViewController {
    typealias Dependecies = HasDetailPlaceViewModel & HasKingfisher & HasOpenGraphService & HasFavoritesViewModel
    
    fileprivate var notificationTokenFavorites: NotificationToken?
    fileprivate var viewModel: DetailPlaceViewModel
    fileprivate let favoritesViewModel: FavoritesViewModel
    fileprivate let kingfisherOptions: KingfisherOptionsInfo
    fileprivate let sevice: OpenGraphService
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var isAddFavorites: Bool {
        return self.favoritesViewModel.checkAddingToFavorites(self.viewModel.place)
    }
    
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
        image.backgroundColor = .shadowGray
        image.kf.indicatorType = .activity
        image.kf.setImage(with: viewModel.place.coverPhoto,
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
        label.attributedText = self.viewModel.title
        
        return label
    }()
    
    fileprivate lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.attributedText = self.viewModel.rating
        return label
    }()
    
    fileprivate lazy var listSubCategoriesView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        let listCategories = ListCategoriesViewController(ListSubCategoriesViewModel(self.viewModel.place.subCategories ?? [],
                                                                                     color: self.viewModel.place.categories?.first?.color))
        
        var frame = listCategories.view.frame
        frame.size.height = view.frame.height
        frame.size.width = view.frame.width
        listCategories.view.frame = frame
        
        addChildViewController(listCategories)
        view.addSubview(listCategories.view)
        listCategories.didMove(toParentViewController: listCategories)
        return view
    }()
    
    fileprivate lazy var favoriteButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: isAddFavorites == true ? "ic_favorite" : "ic_favorite_border")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.mainColor
        button.backgroundColor = UIColor.shadowGray
        button.setTitle(isAddFavorites == true ? " Remove" : " Add", for: .normal)
        button.setTitleColor(UIColor.mainColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15.0)
        button.layer.cornerRadius = 5.0
        button.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
        button.isSelected = !isAddFavorites
        return button
    }()
    
    fileprivate lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_share")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.mainColor
        button.backgroundColor = UIColor.shadowGray
        button.setTitle(" Share", for: .normal)
        button.setTitleColor(UIColor.mainColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15.0)
        button.layer.cornerRadius = 5.0
        button.addTarget(self, action: #selector(sharePlace), for: .touchUpInside)
        return button
    }()
    
    fileprivate let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
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
    
    fileprivate lazy var rightBarButton: UIBarButtonItem = {
        let notifyImage = UIImage(named: "ic_notifications_active")        
        let button = UIBarButtonItem(image: notifyImage, style: .done, target: self, action: #selector(changeNotify))
        return button
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        tableView.snp.remakeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        imageHeader.snp.remakeConstraints { (make) in
            make.top.left.equalTo(self.tableView).offset(10.0)
            make.width.equalTo(100.0)
            make.height.equalTo(140.0)
        }
        
        titlePlace.snp.remakeConstraints { (make) in
            make.top.equalTo(imageHeader)
            make.left.equalTo(imageHeader.snp.right).offset(10.0)
            make.right.equalTo(self.view).offset(-10.0)
            make.bottom.equalTo(ratingLabel.snp.top).offset(-10.0)
        }
        
        ratingLabel.snp.remakeConstraints { (make) in
            make.bottom.equalTo(imageHeader)
            make.left.equalTo(titlePlace)
            make.height.equalTo(15.0)
        }
        
        listSubCategoriesView.snp.remakeConstraints { (make) in
            make.bottom.equalTo(lineView)
            make.right.equalTo(titlePlace)
            make.left.equalTo(ratingLabel.snp.right).offset(10.0)
            make.top.equalTo(titlePlace.snp.bottom)
        }
        
        lineView.snp.remakeConstraints { (make) in
            make.bottom.equalTo(favoriteButton.snp.top).offset(-10.0)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.1)
        }
        
        favoriteButton.snp.makeConstraints { (make) in
            make.right.equalTo(headerView.snp.centerX).offset(-20.0)
            make.bottom.equalToSuperview().offset(-15.0)
            make.size.equalTo(CGSize(width: 120.0, height: 35.0))
        }
        
        shareButton.snp.makeConstraints { (make) in
            make.left.equalTo(headerView.snp.centerX).offset(20.0)
            make.bottom.equalToSuperview().offset(-15.0)
            make.size.equalTo(CGSize(width: 120.0, height: 35.0))
        }
    }
    
    init(_ dependecies: Dependecies) {
        self.viewModel = dependecies.detailViewModel
        self.favoritesViewModel = dependecies.favoritesViewModel
        self.kingfisherOptions = dependecies.kingfisherOptions
        self.sevice = dependecies.service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleNavBar()
        
        if isAddFavorites {
            navigationItem.rightBarButtonItem = rightBarButton
        }
        
        headerView.addSubview(imageHeader)
        headerView.addSubview(titlePlace)
        headerView.addSubview(ratingLabel)
        headerView.addSubview(listSubCategoriesView)
        headerView.addSubview(lineView)
        headerView.addSubview(favoriteButton)
        headerView.addSubview(shareButton)
        tableView.tableHeaderView = headerView
        view.addSubview(tableView)
        updateViewConstraints()
        
        do {
            let realm = try Realm()
            let favorites = realm.objects(Favorites.self)
            notificationTokenFavorites = favorites.observe { [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .update(let favorites, _, _, _):
                    guard favorites.contains(where: { $0.id == self.viewModel.place.id }) else {
                        self.favoriteButton.setTitle(" Add", for: .normal)
                        self.favoriteButton.setImage(UIImage(named: "ic_favorite_border")?.withRenderingMode(.alwaysTemplate), for: .normal)
                        self.navigationItem.rightBarButtonItem = nil
                        return
                    }
                    self.favoriteButton.setTitle(" Remove", for: .normal)
                    self.favoriteButton.setImage(UIImage(named: "ic_favorite")?.withRenderingMode(.alwaysTemplate), for: .normal)
                    self.navigationItem.rightBarButtonItem = self.rightBarButton
                case .error(let error):
                    fatalError("\(error)")
                case .initial:
                    break
                }
            }
        } catch {
            print(error)
        }
        
        tableView.register(DetailDescriptionTableViewCell.self, forCellReuseIdentifier: DetailDescriptionTableViewCell.cellIdentifier)
        tableView.register(DeatilContactsTableViewCell.self, forCellReuseIdentifier: DeatilContactsTableViewCell.cellIdentifier)
        tableView.register(DetailAddressTableViewCell.self, forCellReuseIdentifier: DetailAddressTableViewCell.cellIdentifier)
        tableView.register(DetailWorkDaysTableViewCell.self, forCellReuseIdentifier: DetailWorkDaysTableViewCell.cellIdentifier)
        tableView.register(DetailPaymentTableViewCell.self, forCellReuseIdentifier: DetailPaymentTableViewCell.cellIdentifier)
        tableView.register(DetailParkingTableViewCell.self, forCellReuseIdentifier: DetailParkingTableViewCell.cellIdentifier)
        tableView.register(DetailRestaurantServiceTableViewCell.self, forCellReuseIdentifier: DetailRestaurantServiceTableViewCell.cellIdentifier)
        tableView.register(DetailRestaurantSpecialityTableViewCell.self,
                           forCellReuseIdentifier: DetailRestaurantSpecialityTableViewCell.cellIdentifier)
        
        if viewModel.place.fromFavorites {
            indicatorView.showIndicator()
            viewModel.getInfoAboutPlace(id: viewModel.place.id).asObservable()
                .subscribe(onNext: { [unowned self] (dataSource) in
                    self.viewModel.dataSource = dataSource
                    self.tableView.reloadData()
                    self.indicatorView.hideIndicator()
                }, onError: { (error) in
                    print(error)
                    self.indicatorView.hideIndicator()
                }).disposed(by: disposeBag)
        }
    }
    
    deinit {
        notificationTokenFavorites?.invalidate()
    }
    
    @objc func changeNotify() {
        
    }
    
    @objc func addToFavorites(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        guard sender.isSelected else {
            favoritesViewModel.addToFavorite(place: viewModel.place)
            return
        }
        favoritesViewModel.deleteFromFavorites(id: viewModel.place.id)
    }
    
    @objc func sharePlace() {
        UIImpactFeedbackGenerator().impactOccurred()
        if let image = imageHeader.image {
            let shareController = UIActivityViewController(activityItems: [image, viewModel.place.name ?? ""],
                                                           applicationActivities: nil)
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
        case .description(let text, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailDescriptionTableViewCell.cellIdentifier,
                                                     for: indexPath) as? DetailDescriptionTableViewCell ?? DetailDescriptionTableViewCell()
            
            cell.textDescription = text
            return cell
        case .contact(let contacts, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: DeatilContactsTableViewCell.cellIdentifier,
                                                     for: indexPath) as? DeatilContactsTableViewCell ?? DeatilContactsTableViewCell()
            
            cell.contacts = contacts
            return cell
        case .address(let address, let location, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailAddressTableViewCell.cellIdentifier,
                                                     for: indexPath) as? DetailAddressTableViewCell ?? DetailAddressTableViewCell()
            
            cell.address = address
            cell.location = location
            return cell
        case .workDays(let workDays, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailWorkDaysTableViewCell.cellIdentifier,
                                                     for: indexPath) as? DetailWorkDaysTableViewCell ?? DetailWorkDaysTableViewCell()
            
            cell.workDays = workDays
            return cell
        case .payment(let payments, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailPaymentTableViewCell.cellIdentifier,
                                                     for: indexPath) as? DetailPaymentTableViewCell ?? DetailPaymentTableViewCell()
            
            cell.payments = payments
            return cell
        case .parking(let parkings, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailParkingTableViewCell.cellIdentifier,
                                                     for: indexPath) as? DetailParkingTableViewCell ?? DetailParkingTableViewCell()
            
            cell.parkings = parkings
            return cell
        case .restaurantService(let services, _, let color):
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailRestaurantServiceTableViewCell.cellIdentifier,
                                                     for: indexPath) as? DetailRestaurantServiceTableViewCell ?? DetailRestaurantServiceTableViewCell()
            
            cell.restaurantService = RestaurantService(services, color)
            return cell
        case .restaurantSpeciality(let specialties, _, let color):
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailRestaurantSpecialityTableViewCell.cellIdentifier,
                                                     for: indexPath) as? DetailRestaurantSpecialityTableViewCell ?? DetailRestaurantSpecialityTableViewCell()
            
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
        case .description(_, let height): return height
        case .contact(_, let height): return height
        case .address(_, _, let height): return height
        case .workDays(_, let height): return height
        case .payment(_, let height): return height
        case .parking(_, let height): return height
        case .restaurantService(_, let height, _): return height
        case .restaurantSpeciality(_, let height, _): return height
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y > -23.0 else {
            setTitleNavBar()
            return
        }
        navigationItem.title = viewModel.place.name
    }
}
