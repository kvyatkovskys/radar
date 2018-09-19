//
//  FilterPlacesViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 03/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import Swinject

// color for segmented control
fileprivate extension UIColor {
    static var segmentedColor: UIColor {
        return UIColor(withHex: 0xf82462, alpha: 1.0)
    }
}

final class FilterPlacesViewController: UIViewController, UIPickerViewDelegate {
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModelCategories: FilterCategoriesViewModel
    fileprivate let viewModelDistance: FilterDistanceViewModel
    fileprivate let viewModel: FilterViewModel
    
    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let segmented = UISegmentedControl(items: viewModel.items.map({ $0.title }))
        segmented.selectedSegmentIndex = 0
        segmented.tintColor = UIColor.segmentedColor
        segmented.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
        segmented.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray], for: .normal)
        return segmented
    }()
    
    fileprivate lazy var distanceView: DistanceFilterView = {
        let view = DistanceFilterView()
        return view
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.backgroundColor = .clear
        table.separatorInset.left = 0.0
        return table
    }()
    
    fileprivate let ratingView: RatingPlacesView = {
        return RatingPlacesView()
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10.0)
            make.left.right.equalToSuperview().inset(10.0)
            make.height.equalTo(25.0)
        }
        
        if view.subviews.contains(distanceView) {
            distanceView.snp.makeConstraints { (make) in
                make.top.equalTo(segmentedControl.snp.bottom).offset(5.0)
                make.left.bottom.right.equalToSuperview()
            }
        }
        
        if view.subviews.contains(tableView) {
            tableView.snp.makeConstraints { (make) in
                make.top.equalTo(segmentedControl.snp.bottom).offset(5.0)
                make.left.bottom.right.equalToSuperview()
            }
        }
        
        if view.subviews.contains(ratingView) {
            ratingView.snp.makeConstraints { (make) in
                make.top.equalTo(segmentedControl.snp.bottom).offset(10.0)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-10.0)
            }
        }
    }
    
    init(_ container: Container) {
        self.viewModel = container.resolve(FilterViewModel.self)!
        self.viewModelDistance = container.resolve(FilterDistanceViewModel.self)!
        self.viewModelCategories = container.resolve(FilterCategoriesViewModel.self)!
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(segmentedControl)
        
        tableView.register(CategoriesTableViewCell.self, forCellReuseIdentifier: CategoriesTableViewCell.cellIdentifier)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        Observable.of(viewModelCategories.items)
            .bind(to: tableView.rx
                .items(cellIdentifier: CategoriesTableViewCell.cellIdentifier,
                       cellType: CategoriesTableViewCell.self)) { [unowned self] (index, model, cell) in
                        cell.title = model.category.title
                        cell.type = model.category
                        cell.select = self.viewModelCategories.selectIndexes.contains(index)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [unowned self] (index) in
                if self.viewModelCategories.selectIndexes.contains(index.row) {
                    self.viewModelCategories.deletedIndex(index)
                } else {
                    self.viewModelCategories.addIndex(index)
                }
                self.tableView.reloadRows(at: [index], with: .automatic)
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)
        
        distanceView.sliderDistance.asObserver()
            .subscribe(onNext: { [unowned self] (value) in
                self.viewModelDistance.setNewDistance(value: value)
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)
        
        distanceView.nearMe.asObservable()
            .subscribe(onNext: { [unowned self] (isOn) in
                self.viewModelDistance.setMinDistance(value: isOn)
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)
        
        segmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [unowned self] (index) in
                let type = TypeFilter(rawValue: index)
                switch type {
                case .distance?:
                    self.navigationController?.preferredContentSize = CGSize(width: 250.0, height: 200.0)
                    self.view.subviews.filter({ $0 is UITableView || $0 is RatingPlacesView }).forEach({ $0.removeFromSuperview() })
                    self.view.addSubview(self.distanceView)
                case .categories?:
                    self.navigationController?.preferredContentSize = CGSize(width: 250.0, height: Double(self.viewModelCategories.items.count * 60))
                    self.view.subviews.filter({ $0 is DistanceFilterView || $0 is RatingPlacesView }).forEach({ $0.removeFromSuperview() })
                    self.view.addSubview(self.tableView)
                case .rating?:
                    self.navigationController?.preferredContentSize = CGSize(width: 250.0, height: 200.0)
                    self.view.subviews.filter({ $0 is DistanceFilterView || $0 is UITableView }).forEach({ $0.removeFromSuperview() })
                    self.view.addSubview(self.ratingView)
                case .none:
                    break
                }
                self.updateViewConstraints()
                }, onError: { (error) in
                    print(error)
            })
            .disposed(by: disposeBag)
        
        ratingView.chooseRating.asObserver()
            .subscribe(onNext: { (type) in
                do {
                    let realm = try Realm()
                    let oldType = realm.objects(FilterSelectedRating.self).first
                    try realm.write {
                        guard let oldType = oldType else {
                            let selectedRating = FilterSelectedRating()
                            selectedRating.rating = type.rawValue
                            realm.add(selectedRating)
                            return
                        }
                        oldType.rating = type.rawValue
                    }
                } catch {
                    print(error)
                }
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}

extension FilterPlacesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
}
