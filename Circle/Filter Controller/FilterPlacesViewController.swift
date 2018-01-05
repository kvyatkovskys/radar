//
//  FilterPlacesViewController.swift
//  Circle
//
//  Created by Kviatkovskii on 03/01/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift

protocol FilterPlacesDelegate: class {
    func selectDistance(value: Double)
}

final class FilterPlacesViewController: UIViewController {
    typealias Dependecies = HasFilterPlacesViewModel & HasFilterPlacesDelegate
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModelDistance: FilterDistanceViewModel
    fileprivate let viewModel: FilterViewModel
    fileprivate weak var delegate: FilterPlacesDelegate?
    fileprivate var pickerDataSource: DistancePickerViewDataSource?
    fileprivate var pickerDelegate: DistancePickerViewDelegate?
    
    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let segmented = UISegmentedControl(items: viewModel.items.map({ $0.title }))
        segmented.selectedSegmentIndex = 0
        return segmented
    }()
    
    fileprivate lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10.0)
            make.left.right.equalToSuperview().inset(15.0)
            make.height.equalTo(25.0)
        }
        
        pickerView.snp.makeConstraints { (make) in
            make.top.equalTo(segmentedControl.snp.bottom).offset(5.0)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    init(_ dependecies: Dependecies) {
        self.viewModel = dependecies.viewModel
        self.viewModelDistance = dependecies.viewModelDistance
        self.delegate = dependecies.delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(segmentedControl)
        view.addSubview(pickerView)
        updateViewConstraints()
        
        pickerDataSource = DistancePickerViewDataSource(pickerView, viewModelDistance)
        pickerDelegate = DistancePickerViewDelegate(pickerView, viewModelDistance.items)
        pickerDelegate?.selectValue.asObserver().subscribe(onNext: { [unowned self] (value) in
            print(value)
            UserDefaults.standard.set(value, forKey: "FilterDistance")
            self.delegate?.selectDistance(value: value)
        }, onError: { (error) in
            print(error)
        }).disposed(by: disposeBag)
        
        segmentedControl.rx.selectedSegmentIndex.subscribe(onNext: { (index) in
            let type = TypeFilter(rawValue: index)
            switch type {
            case .distance?:
                self.navigationController?.preferredContentSize = CGSize(width: 250.0, height: 200.0)
            case .categories?:
                self.navigationController?.preferredContentSize = CGSize(width: 250.0, height: 500.0)
            case .none:
                break
            }
        }, onError: { (error) in
            print(error)
        }).disposed(by: disposeBag)
    }
}
