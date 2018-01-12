//
//  FilterPlacesViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 03/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift

// color for segmented control
fileprivate extension UIColor {
    static var segmentedColor: UIColor {
        return UIColor(withHex: 0x34495e, alpha: 1.0)
    }
}

protocol FilterPlacesDelegate: class {
    func selectDistance(value: Double)
}

final class FilterPlacesViewController: UIViewController {
    typealias Dependecies = HasFilterPlacesViewModel & HasFilterPlacesDelegate
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModelCategories: FilterCategoriesViewModel
    fileprivate let viewModelDistance: FilterDistanceViewModel
    fileprivate let viewModel: FilterViewModel
    fileprivate weak var delegate: FilterPlacesDelegate?
    fileprivate var pickerDataSource: DistancePickerViewDataSource?
    //swiftlint:disable weak_delegate
    fileprivate var pickerDelegate: DistancePickerViewDelegate?
    fileprivate var tableDataSource: CategoriesTableViewDataSource?
    fileprivate var tableDelegate: CategoriesTableViewDelegate?
    
    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let segmented = UISegmentedControl(items: viewModel.items.map({ $0.title }))
        segmented.selectedSegmentIndex = 0
        segmented.tintColor = UIColor.segmentedColor
        return segmented
    }()
    
    fileprivate lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView(frame: CGRect.zero)
        table.backgroundColor = .clear
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
        
        if view.subviews.contains(pickerView) {
            pickerView.snp.makeConstraints { (make) in
                make.top.equalTo(segmentedControl.snp.bottom).offset(5.0)
                make.left.bottom.right.equalToSuperview()
            }
        }
        
        if view.subviews.contains(tableView) {
            tableView.snp.makeConstraints { (make) in
                make.top.equalTo(segmentedControl.snp.bottom).offset(10.0)
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
    
    init(_ dependecies: Dependecies) {
        self.viewModel = dependecies.viewModel
        self.viewModelDistance = dependecies.viewModelDistance
        self.viewModelCategories = dependecies.viewModelCategories
        self.delegate = dependecies.delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(segmentedControl)
        
        pickerDataSource = DistancePickerViewDataSource(pickerView, viewModelDistance)
        pickerDelegate = DistancePickerViewDelegate(pickerView, viewModelDistance.items)
        
        tableView.register(CategoriesTableViewCell.self, forCellReuseIdentifier: CategoriesTableViewCell.cellIdentifier)
        tableDataSource = CategoriesTableViewDataSource(tableView, viewModelCategories)
        tableDelegate = CategoriesTableViewDelegate(tableView, viewModelCategories)
        
        pickerDelegate?.selectValue.asObserver().subscribe(onNext: { [weak delegate = self.delegate] (value) in
            UserDefaults.standard.set(value, forKey: "FilterDistance")
            delegate?.selectDistance(value: value)
        }, onError: { (error) in
            print(error)
        }).disposed(by: disposeBag)
        
        segmentedControl.rx.selectedSegmentIndex.subscribe(onNext: { [unowned self] (index) in
            let type = TypeFilter(rawValue: index)
            switch type {
            case .distance?:
                self.navigationController?.preferredContentSize = CGSize(width: 250.0, height: 200.0)
                self.view.subviews.filter({ $0 is UITableView || $0 is RatingPlacesView }).forEach({ $0.removeFromSuperview() })
                self.view.addSubview(self.pickerView)
                self.updateViewConstraints()
            case .categories?:
                self.navigationController?.preferredContentSize = CGSize(width: 250.0,
                                                                         height: Double(self.viewModelCategories.items.count) * 61.0)
                self.view.subviews.filter({ $0 is UIPickerView || $0 is RatingPlacesView }).forEach({ $0.removeFromSuperview() })
                self.view.addSubview(self.tableView)
                self.updateViewConstraints()
            case .rating?:
                self.navigationController?.preferredContentSize = CGSize(width: 250.0, height: 200.0)
                self.view.subviews.filter({ $0 is UIPickerView || $0 is UITableView }).forEach({ $0.removeFromSuperview() })
                self.view.addSubview(self.ratingView)
                self.updateViewConstraints()
            case .none:
                break
            }
        }, onError: { (error) in
            print(error)
        }).disposed(by: disposeBag)
    }
}
