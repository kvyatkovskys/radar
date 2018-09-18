//
//  PlacesViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 08/12/2017.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import SnapKit
import MapKit
import RxSwift
import RxCocoa
import Kingfisher
import RealmSwift
import Swinject

final class PlacesViewController: UIViewController {
    fileprivate var notificationTokenCategories: NotificationToken?
    fileprivate var notificationTokenDistance: NotificationToken?
    fileprivate var viewModel: PlaceViewModel
    fileprivate let disposeBag = DisposeBag()
    fileprivate let tableView: KSTableView = {
        let table = KSTableView()
        table.isEnabledRefresh = true
        return table
    }()
    
    lazy var rightBarButton: UIBarButtonItem = {
        let categoriesImage = UIImage(named: "ic_filter_list")?.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: categoriesImage, style: .done, target: self, action: #selector(openFilter))
        return button
    }()
    
    lazy var leftBarButton: UIBarButtonItem = {
        var categoriesImage = UIImage()
        
        switch viewModel.typeView {
        case .table:
            categoriesImage = UIImage(named: "ic_map")!.withRenderingMode(.alwaysTemplate)
        case .map:
            categoriesImage = UIImage(named: "ic_view_list")!.withRenderingMode(.alwaysTemplate)
        }

        let button = UIBarButtonItem(image: categoriesImage, style: .done, target: self, action: #selector(setView))
        button.tag = viewModel.typeView.rawValue
        setView(sender: button)
        return button
    }()
    
    fileprivate lazy var indicatorView: ActivityIndicatorView = {
        return ActivityIndicatorView(container: self.view)
    }()
    
    fileprivate func updateConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        super.updateViewConstraints()
    }
    
    init(_ container: Container) {
        self.viewModel = container.resolve(PlaceViewModel.self)!
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.leftBarButtonItem = leftBarButton
        
        viewModel.locationService.start()
        
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.cellIndetifier)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        tableView.refresh.rx.controlEvent(.valueChanged)
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ [unowned self] _ -> Observable<PlaceDataModel> in
                self.viewModel.locationService.start()
                return self.viewModel.places.asObservable()
                    .do(onError: { (error) in
                        print(error)
                        self.tableView.refresh.endRefreshing()
                    }, onCompleted: {
                        self.tableView.refresh.endRefreshing()
                    })
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        viewModel.places.asObservable()
            .flatMap({ (places) -> Observable<[PlaceModel]>in
                return Observable.just(places.data)
            })
            .filter({ [unowned self, weak userLocation = self.viewModel.userLocation] (places) -> Bool in
                self.indicatorView.hideIndicator()
                guard self.viewModel.typeView == .map else {
                    return true
                }
                self.viewModel.reloadMap(places, userLocation)
                return false
            })
            .bind(to: tableView.rx
                .items(cellIdentifier: PlaceTableViewCell.cellIndetifier,
                       cellType: PlaceTableViewCell.self)) { (_, place, cell) in
                        cell.title = place.name
                        cell.rating = place.rating
                        cell.titleCategory = place.categories?.first?.title
                        cell.colorCategory = place.categories?.first?.color
                        cell.imageCell.kf.indicatorType = .activity
                        cell.imageCell.kf.setImage(with: place.coverPhoto,
                                                   placeholder: nil,
                                                   options: self.viewModel.kingfisherOptions,
                                                   progressBlock: nil,
                                                   completionHandler: nil)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(PlaceModel.self)
            .subscribe(onNext: { [unowned self] (place) in
                self.viewModel.openDetailPlace(place, FavoritesViewModel())
            })
            .disposed(by: disposeBag)
        
        do {
            let realm = try Realm()
            let selectedCategories = realm.objects(FilterSelectedCategory.self)
            let filterDistance = realm.objects(FilterSelectedDistance.self)
            
            notificationTokenCategories = selectedCategories.observe({ [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .update:
                    self.indicatorView.showIndicator()
                    guard self.viewModel.searchForMinDistance == false else {
                        self.loadPlacesLocation(self.viewModel.userLocation, distance: 100.0)
                        return
                    }
                    self.loadPlacesLocation(self.viewModel.userLocation)
                case .error(let error):
                    fatalError("\(error)")
                case .initial:
                    break
                }
            })
            
            notificationTokenDistance = filterDistance.observe({ [unowned self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    break
                case .update(let filter, _, _, _):
                    self.indicatorView.showIndicator()
                    let searchFilter = filter.first
                    self.viewModel.searchForMinDistance = searchFilter?.searchForMinDistance ?? false
                    guard self.viewModel.searchForMinDistance == false else {
                        self.loadPlacesLocation(self.viewModel.userLocation, distance: 100.0)
                        return
                    }
                    self.loadPlacesLocation(self.viewModel.userLocation, distance: searchFilter?.distance ?? 1000.0)
                case .error(let error):
                    fatalError("\(error)")
                }
            })
        } catch {
            print(error)
        }
        
        viewModel.locationService.userLocation.asObserver()
            .filter({ (locationMonitoring) -> Bool in
                if self.tableView.refresh.isRefreshing {
                    self.tableView.refresh.endRefreshing()
                }
                return self.viewModel.userLocation == nil || locationMonitoring.monitoring
            })
            .map({ [unowned self] (locationMonitoring) in
                self.indicatorView.showIndicator()
                self.viewModel.userLocation = locationMonitoring.location
                guard self.viewModel.searchForMinDistance == false else {
                    self.loadPlacesLocation(locationMonitoring.location, distance: 100.0)
                    return
                }
                self.loadPlacesLocation(locationMonitoring.location)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    deinit {
        notificationTokenCategories?.invalidate()
        notificationTokenDistance?.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.locationService.checkAuthorized()
    }
    
    @objc func setView(sender: UIBarButtonItem?) {
        let type = TypeView(rawValue: sender?.tag ?? 0)!
        switch type {
        case .map:
            sender?.tag = TypeView.table.rawValue
            view.subviews.forEach({ $0.removeFromSuperview() })
            viewModel.changeTypeView(.map)
            viewModel.openMap(viewModel.places.value.data, viewModel.userLocation)
            navigationItem.leftBarButtonItem?.image = UIImage(named: "ic_view_list")!.withRenderingMode(.alwaysTemplate)
        case .table:
            sender?.tag = TypeView.map.rawValue
            let vc = childViewControllers.last
            vc?.view.removeFromSuperview()
            vc?.removeFromParentViewController()
            viewModel.changeTypeView(.table)
            view.addSubview(tableView)
            updateConstraints()
            navigationItem.leftBarButtonItem?.image = UIImage(named: "ic_map")!.withRenderingMode(.alwaysTemplate)
        }
    }
    
    // MARK: PlaceViewModel
    @objc func openFilter() {
        viewModel.openFilter()
    }
    
    fileprivate func loadMorePlacesLocation(url: URL) {
        viewModel.getMorePlaces(url: url)
    }
    
    fileprivate func loadPlacesLocation(_ location: CLLocation?, distance: Double = FilterDistanceViewModel().defaultDistance) {
        viewModel.getPlaces(location: location, distance: distance)
    }
}

extension PlacesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightTableCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 3
        if let url = viewModel.places.value.next, indexPath.row == lastRowIndex {
            loadMorePlacesLocation(url: url)
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.8,
                       options: .curveLinear,
                       animations: { cell?.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) },
                       completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.1) {
            cell?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
